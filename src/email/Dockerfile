FROM ruby:3.2.2-slim AS builder
WORKDIR /src/email

COPY ./src/email .

RUN apt-get update && apt-get install build-essential -y && bundle install

#-----------------------------------------------------------------------------
FROM ruby:3.2.2-slim AS runtime
WORKDIR /app/email
COPY ./src/email .
RUN chmod o+r Gemfile.lock

COPY --from=builder /usr/local/bundle /usr/local/bundle
EXPOSE ${EMAIL_PORT}

ENTRYPOINT bundle exec ruby email_server.rb