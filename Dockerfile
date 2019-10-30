FROM ruby:2.5.7-slim

# Add basic binaries (first pass)
RUN apt-get update \
  && apt-get install -y curl gpg \
  # Clean up the apt cache
  && rm -rf /var/lib/apt/lists/*

# Specify a major version of Node.js to download and install
ENV NODEJS_MAJOR_VERSION=10

# Set a variable to match the name of the current release codename
ENV DISTRIBUTION_CODENAME=buster

# Add the Node.js apt package repository 
RUN echo 'deb https://deb.nodesource.com/node_${NODEJS_MAJOR_VERSION}.x ${DISTRIBUTION_CODENAME} main' > /etc/apt/sources.list.d/nodesource.list \
  && curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

# Add basic binaries (second pass)
RUN apt-get update \
  && apt-get install -y g++ gcc libfontconfig libpq-dev make nodejs patch xz-utils \
  # Clean up the apt cache
  && rm -rf /var/lib/apt/lists/*

# Download, extract and install PhantomJS from archive hosted at bitbucket
RUN curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -O \
  # Extract and clean up the PhantomJS archive
  && tar xf phantomjs-2.1.1-linux-x86_64.tar.bz2 && rm phantomjs-2.1.1-linux-x86_64.tar.bz2 \
  # Install PhantomJS binary to /usr/local/bin
  && mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin \
  # Clean up extra (un-needed) PhantomJS files
  && rm -rf phantomjs-2.1.1-linux-x86_64/

# Work around an issue with running "phantomjs --version"
ENV OPENSSL_CONF=/etc/ssl/

# Install Yarn
RUN npm install -g yarn

# Make the "/refugerestrooms" folder, run all subsequent commands in that folder
RUN mkdir /refugerestrooms
WORKDIR /refugerestrooms

# Install Ruby gems with Bundler
COPY Gemfile Gemfile.lock /refugerestrooms/
RUN bundle install

# Install Node.js packages with Yarn
COPY package.json yarn.lock /refugerestrooms/
RUN yarn install --pure-lockfile
