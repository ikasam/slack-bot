FROM ruby:alpine
MAINTAINER Masaki Kanno
RUN apk upgrade --no-cache \ 
    && apk add --no-cache --virtual build-dependencies \
      build-base \ 
    && apk add --no-cache \
      libxml2-dev \
      libxslt-dev \
      libstdc++
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app
RUN bundle install
RUN apk del build-dependencies
COPY slack-bot.rb /usr/src/app
CMD ["ruby", "slack-bot.rb"]
