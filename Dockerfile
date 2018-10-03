# We are using wkhtmltopdf to generate PDF files. Unfortunately according to 
# madnight, compiling wkhtmltopdf from scratch will take hours even with the
# largest ec2 instance. So here we take the precompiled binary from the other
# image available on Dockerfile - we will get to this in final stage.
#
FROM madnight/docker-alpine-wkhtmltopdf as wkhtmltopdf_image

# Builder stage
FROM elixir:1.7.3 as builder

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
ARG SENDGRID_API_KEY
ARG SENDGRID_SENDER_EMAIL

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
    HOSTED_PAYMENT_URL=$HOSTED_PAYMENT_URL \
    SENDGRID_API_KEY=$SENDGRID_API_KEY \
    SENDGRID_SENDER_EMAIL=$SENDGRID_SENDER_EMAIL

WORKDIR /snitch

# Umbrella
COPY mix.exs mix.lock ./
COPY config config

# Apps
COPY apps apps
RUN mix do local.hex --force, local.rebar --force
RUN mix do deps.get, deps.compile

WORKDIR /snitch
COPY rel rel

RUN mix release --env=prod --verbose

### Release
FROM staticfloat/nginx-certbot

RUN apt-get update \
  && apt-get -y install curl tar file xz-utils build-essential cron vim \
  && apt-get -y install python-certbot-nginx \
  && apt-get -y install imagemagick

ENV MIX_ENV=prod \
    SHELL=/bin/bash \
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
    HOSTED_PAYMENT_URL=$HOSTED_PAYMENT_URL \
    SENDGRID_API_KEY=$SENDGRID_API_KEY \
    SENDGRID_SENDER_EMAIL=$SENDGRID_SENDER_EMAIL

# nginx conf
COPY config/deploy/live/conf.d/* /etc/nginx/conf.d/
RUN mkdir -p /etc/letsencrypt/live/admin.aviacommerce.org \
  && mkdir -p /etc/letsencrypt/live/api.aviacommerce.org
COPY config/deploy/live/admin.aviacommerce.org/* /etc/letsencrypt/live/admin.aviacommerce.org/
COPY config/deploy/live/api.aviacommerce.org/* /etc/letsencrypt/live/api.aviacommerce.org/

WORKDIR /snitch
COPY --from=wkhtmltopdf_image /bin/wkhtmltopdf /usr/bin/
COPY --from=builder snitch/_build/prod/rel/snitch/releases/0.0.1/snitch.tar.gz .
RUN tar zxf snitch.tar.gz && rm snitch.tar.gz

# RUN certbot -n --authenticator standalone --installer nginx -d api.aviacommerce.org -d admin.aviacommerce.org --pre-hook "service nginx stop" --post-hook "service nginx start" --agree-tos --email "hello@aviabird.com"

RUN echo "nginx && /snitch/bin/snitch foreground" >> run.sh

CMD ["sh", "/snitch/run.sh"]
