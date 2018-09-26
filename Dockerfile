# We are using wkhtmltopdf to generate PDF files. Unfortunately according to 
# madnight, compiling wkhtmltopdf from scratch will take hours even with the
# largest ec2 instance. So here we take the precompiled binary from the other
# image available on Dockerfile - we will get to this in final stage.
#
FROM madnight/docker-alpine-wkhtmltopdf as wkhtmltopdf_image

# Builder stage
FROM bitwalker/alpine-elixir-phoenix as builder

ARG PHOENIX_SECRET_KEY_BASE
ARG SESSION_COOKIE_NAME
ARG SESSION_COOKIE_SIGNING_SALT
ARG SESSION_COOKIE_ENCRYPTION_SALT
ARG DATABASE_URL
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG BUCKET_NAME
ARG AWS_DEFAULT_REGION
ARG FRONTEND_CHECKOUT_URL
ARG HOSTED_PAYMENT_URL

ENV MIX_ENV=prod \
    PHOENIX_SECRET_KEY_BASE=$PHOENIX_SECRET_KEY_BASE \
    SESSION_COOKIE_NAME=$SESSION_COOKIE_NAME \
    SESSION_COOKIE_SIGNING_SALT=$SESSION_COOKIE_SIGNING_SALT \
    SESSION_COOKIE_ENCRYPTION_SALT=$SESSION_COOKIE_ENCRYPTION_SALT \
    DATABASE_URL=$DATABASE_URL \
    AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    BUCKET_NAME=$BUCKET_NAME \
    AWS_REGION=$AWS_DEFAULT_REGION \
    FRONTEND_CHECKOUT_URL=$FRONTEND_CHECKOUT_URL \
    HOSTED_PAYMENT_URL=$HOSTED_PAYMENT_URL

WORKDIR /snitch

# Umbrella
COPY mix.exs mix.lock ./
COPY config config
COPY env env
RUN source env/local.env

# Apps
COPY apps apps
RUN mix do local.hex --force, local.rebar --force
RUN mix do deps.get, deps.compile

WORKDIR /snitch
COPY rel rel

RUN mix release --env=prod --verbose

### Release

FROM alpine:latest

# We need bash and openssl for Phoenix
RUN apk upgrade --no-cache && \
    apk add --no-cache bash openssl && \
    apk --update add imagemagick

ENV MIX_ENV=prod \
    SHELL=/bin/bash

WORKDIR /snitch

COPY --from=wkhtmltopdf_image /bin/wkhtmltopdf /usr/bin/

COPY --from=builder /snitch/_build/prod/rel/snitch/releases/0.0.1/snitch.tar.gz .

RUN tar zxf snitch.tar.gz && rm snitch.tar.gz

CMD ["/snitch/bin/snitch", "foreground"]
