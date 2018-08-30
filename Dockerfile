# Alias this container as builder:
FROM bitwalker/alpine-elixir-phoenix as builder

ARG PHOENIX_SECRET_KEY_BASE
ARG SESSION_COOKIE_NAME
ARG SESSION_COOKIE_SIGNING_SALT
ARG SESSION_COOKIE_ENCRYPTION_SALT
ARG DATABASE_URL

ENV MIX_ENV=prod \
    PHOENIX_SECRET_KEY_BASE=$PHOENIX_SECRET_KEY_BASE \
    SESSION_COOKIE_NAME=$SESSION_COOKIE_NAME \
    SESSION_COOKIE_SIGNING_SALT=$SESSION_COOKIE_SIGNING_SALT \
    SESSION_COOKIE_ENCRYPTION_SALT=$SESSION_COOKIE_ENCRYPTION_SALT \
    DATABASE_URL=$DATABASE_URL

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

FROM alpine:latest

# We need bash and openssl for Phoenix
RUN apk upgrade --no-cache && \
    apk add --no-cache bash openssl

ENV MIX_ENV=prod \
    SHELL=/bin/bash

WORKDIR /snitch

COPY --from=builder /snitch/_build/prod/rel/snitch/releases/0.0.1/snitch.tar.gz .

RUN tar zxf snitch.tar.gz && rm snitch.tar.gz

CMD ["/snitch/bin/snitch", "foreground"]
