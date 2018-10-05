FROM ruby:2.3.7-alpine3.7

ENV POSTGRES postgresql postgresql-dev
ENV RAILS ruby-nokogiri tzdata
ENV YARN yarn

RUN apk update && apk upgrade \
    && apk --no-cache add $POSTGRES $RAILS $YARN \
    && apk --no-cache add --virtual build-dependencies build-base

RUN yarn global add phantomjs-prebuilt@2.1.16

WORKDIR /refugerestrooms

ADD package.json yarn.lock /refugerestrooms/
RUN yarn --pure-lockfile

ADD Gemfile Gemfile.lock /refugerestrooms/
RUN bundle install && bundle clean

RUN apk del build-dependencies && rm /var/cache/apk/*
