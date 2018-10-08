FROM ruby:2.3.7
ENV PHANTOM_JS=2.1.1

# Add the apt-repository for the latest node.js and install node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs

# Add the apt repository for yarn and install yarn
RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn

# Install PhantomJS
RUN cd ~ && \
  export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" && \
  wget https://github.com/Medium/phantomjs/releases/download/v2.1.1/$PHANTOM_JS.tar.bz2 && \
  tar xvjf $PHANTOM_JS.tar.bz2 && \
  mv $PHANTOM_JS /usr/local/share && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

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
