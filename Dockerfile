FROM ruby:2.3.7-slim

# Add basic binaries
RUN apt-get update \
  && apt-get install -y curl gcc gnupg make \
  postgresql-server-dev-9.6 zlib1g-dev

# Add the apt-repository for the latest node.js, install node.js,
# and clean up the apt cache
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

# Install yarn with npm
RUN npm install -g yarn

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
