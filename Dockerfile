FROM ruby:2.5.3-slim

# Add basic binaries
RUN apt-get update \
  && apt-get install -y curl gcc libpq-dev make patch xz-utils \
  # Clean up the apt cache
  && rm -rf /var/lib/apt/lists/*

# Specify a version of Node.js to download and install
ENV NODEJS_VER="v10.15.0"

# Download and extract Nodejs from archive supplied by nodejs.org
RUN curl https://nodejs.org/dist/$NODEJS_VER/node-$NODEJS_VER-linux-x64.tar.xz -o nodejs.tar.xz \
  && tar xf nodejs.tar.xz

# Add Node.js binaries to PATH (includes Node and NPM, will include Yarn)
ENV PATH="/node-$NODEJS_VER-linux-x64/bin/:${PATH}"

# Install Yarn
RUN npm install -g yarn

# Install PhantomJS
RUN yarn global add phantomjs-prebuilt

# Make the "/refugerestrooms" folder, run all subsequent commands in that folder
RUN mkdir /refugerestrooms
WORKDIR /refugerestrooms

# Install gems with Bundler
COPY Gemfile Gemfile.lock /refugerestrooms/
RUN bundle install

# Install node packages with Yarn
COPY package.json yarn.lock /refugerestrooms/
RUN yarn --pure-lockfile
