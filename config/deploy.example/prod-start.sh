until
  docker build -t snitch:latest \
    --build-arg PHOENIX_SECRET_KEY_BASE=$PHOENIX_SECRET_KEY_BASE \
    --build-arg SESSION_COOKIE_NAME=session_cookie_name \
    --build-arg SESSION_COOKIE_SIGNING_SALT=super_secret_cookie_signing_salt \
    --build-arg SESSION_COOKIE_ENCRYPTION_SALT=super_secret_cookie_encryption_salt \
    --build-arg DATABASE_URL=$DATABASE_URL \
    --build-arg AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    --build-arg AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    --build-arg BUCKET_NAME=$BUCKET_NAME \
    --build-arg AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    --build-arg FRONTEND_CHECKOUT_URL=$FRONTEND_CHECKOUT_URL \
    --build-arg HOSTED_PAYMENT_URL=$HOSTED_PAYMENT_URL \
    --build-arg SENDGRID_SENDER_EMAIL=$SENDGRID_SENDER_EMAIL \
    --build-arg SENDGRID_API_KEY=$SENDGRID_API_KEY \
    --build-arg ELASTIC_HOST=$ELASTIC_HOST \
    . -f ./config/docker/prod/Dockerfile; do
  echo Docker build failed, retrying in 1 seconds...
  sleep 1
done

docker run --rm -it -p 4001:4001 -p 3000:3000 -p 5432:5432 -e API_PORT=3000 -e ADMIN_PORT=4001 snitch:latest /bin/bash
