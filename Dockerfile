FROM ruby:2.3.7-slim

# Add basic binaries and clean up the apt cache
RUN apt-get update \
  && apt-get install -y bzip2 curl gnupg \
  && rm -rf /var/lib/apt/lists/*

# Add the apt-repository for the latest node.js and install node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs

# Add the apt repository for yarn and install yarn
RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn

# Establish working directory in Docker container's /refugerestrooms folder
RUN mkdir /refugerestrooms
WORKDIR /refugerestrooms

# Install Gems
COPY Gemfile /refugerestrooms/Gemfile
COPY Gemfile.lock /refugerestrooms/Gemfile.lock
RUN bundle install

# Install Node.js packages
COPY package.json yarn.lock /refugerestrooms/
RUN yarn --pure-lockfile
