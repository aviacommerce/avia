# We are using wkhtmltopdf to generate PDF files. Unfortunately according to
# madnight, compiling wkhtmltopdf from scratch will take hours even with the
# largest ec2 instance. So here we take the precompiled binary from the other
# image available on Dockerfile - we will get to this in final stage.
#

# Builder stage
FROM elixir:1.7.3-slim as builder

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
ARG FRONTEND_URL
ARG BACKEND_URL
ARG ELASTIC_HOST

# Install essential packages for application build
RUN apt-get clean \
  && apt-get update \
  && apt-get install -y apt-utils apt-transport-https curl git make inotify-tools gnupg g++ \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash \
  && apt-get install -y nodejs yarn

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
    SENDGRID_SENDER_EMAIL=$SENDGRID_SENDER_EMAIL \
    FRONTEND_URL=$FRONTEND_URL \
    BACKEND_URL=$BACKEND_URL \
    ELASTIC_HOST=$ELASTIC_HOST

WORKDIR /snitch

# Umbrella
COPY mix.exs mix.lock ./
COPY config config

# Apps
COPY apps apps
RUN mix do local.hex --force, local.rebar --force
RUN mix do deps.get, deps.compile

# Create assets build for admin app
RUN cd apps/admin_app/assets \
  && yarn install \
  && yarn deploy \
  && cd .. \
  && mix phx.digest

WORKDIR /snitch
COPY rel rel

RUN mix release --env=prod --verbose

### Release
FROM staticfloat/nginx-certbot

RUN apt-get clean \
  && apt-get update \
  && apt-get -y install curl tar file xz-utils build-essential cron \
  && apt-get -y install python-certbot-nginx \
  && apt-get -y install imagemagick wkhtmltopdf xvfb \
  # Resolves issue `QXcbConnection: Could not connect to display`
  # https://github.com/JazzCore/python-pdfkit/wiki/Using-wkhtmltopdf-without-X-server#debianubuntu
  && printf '#!/bin/bash\nxvfb-run -a --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf -q $*' > /usr/bin/wkhtmltopdf.sh \
  && chmod a+x /usr/bin/wkhtmltopdf.sh \
  && ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf \
  && apt-get install -y --no-install-recommends locales \
  # Supress earlang vm waning form locale issue
  && export LANG=en_US.UTF-8 \
  && echo $LANG UTF-8 > /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=$LANG \
  # Remove unwanted package after use
  && apt-get purge -y curl file xz-utils build-essential locales \
  && apt-get -y autoremove \
  && apt-get -y clean

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
    SENDGRID_SENDER_EMAIL=$SENDGRID_SENDER_EMAIL \
    FRONTEND_URL=$FRONTEND_URL \
    BACKEND_URL=$BACKEND_URL

# nginx conf
COPY config/deploy/conf.d /etc/nginx/conf.d
COPY config/deploy/letsencrypt /etc/letsencrypt

WORKDIR /snitch

COPY --from=builder snitch/_build/prod/rel/snitch/releases/0.0.1/snitch.tar.gz .
RUN tar zxf snitch.tar.gz && rm snitch.tar.gz

# RUN certbot -n --authenticator standalone --installer nginx -d api.aviacommerce.org -d admin.aviacommerce.org --pre-hook "service nginx stop" --post-hook "service nginx start" --agree-tos --email "hello@aviabird.com"

RUN echo "nginx && /snitch/bin/snitch foreground" >> run.sh

CMD ["sh", "/snitch/run.sh"]
