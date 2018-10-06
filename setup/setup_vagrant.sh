#!/bin/bash
# This script is run from vagrant to setup packages
# It's only tested with ubuntu 18.04
set -e

REFUGE_PATH=/vagrant
PHANTOM_JS=2.1.1

# Add the apt repository for yarn
echo 'Adding the Yarn APT repository'
if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
  curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
else
  echo 'the Yarn repository is already configured. skipping...'
fi

# Add the APT repository for the latest Node.js
echo 'Adding the Node.js APT repository'
if [ ! -f /etc/apt/sources.list.d/nodesource.list ]; then
  curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
else
  echo 'the Node.js repository is already configured. skipping...'
fi

# Install a bunch of required packages
#(Who knows if these are actually needed??)

# Install PhantomJS
echo 'Installing PhantomJS'
if [ ! -d /usr/local/bin/phantomjs/ ]; then
  export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" && \
    wget https://github.com/Medium/phantomjs/releases/download/v2.1.1/$PHANTOM_JS.tar.bz2 && \
    tar xvjf $PHANTOM_JS.tar.bz2 && \
    sudo mv $PHANTOM_JS /usr/local/share && \
    sudo ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin
else
  echo 'PhantomJS is already installed and configured. skipping...'
fi

# required packages
declare -A packages
packages=(
  ["git"]=""
  ["libreadline-dev"]=""
  ["nodejs"]=""
  ["postgresql-server-dev-10"]=""
  ["postgresql-contrib"]=""
  ["yarn"]=""
)

sudo apt-get update
for package in "${!packages[@]}"
do
  version=${packages["$package"]}
  if dpkg -s $package 2>/dev/null | grep -q "$version"; then
    echo $package' installed, skipping'
  else
    echo "installing $package, version $version..."
    sudo apt-get install -y -q $package$version
  fi
done

# Install rvm
echo 'installing rvm...'
cd
if ! [ -d .rvm ]; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

  \curl -sSL https://get.rvm.io | bash -s stable
else
  echo 'rvm installed, skipping'
fi

# Add rvm to PATH
source /home/vagrant/.rvm/scripts/rvm

# Install ruby
ruby_version=$(cat $REFUGE_PATH/.ruby-version | tr -d '\n\r')
if rvm list rubies | grep $ruby_version; then
  echo 'ruby '$ruby_version' installed, skipping...'
else
  echo 'install ruby '$ruby_version
  rvm install $ruby_version
fi

# Set local ruby version
rvm use $ruby_version

# Install bundle reqs
cd $REFUGE_PATH
if which bundle; then
  echo 'bundler installed, skipping'
else
  echo 'Installing bundler...'
  gem install bundler --no-rdoc --no-ri -q
fi
echo 'Running bundle install...'
bundle install --gemfile=$REFUGE_PATH/Gemfile

# Install Node.js dependencies using yarn
yarn --pure-lockfile

# Change permissions on pg_hba.conf
pg_hba=/etc/postgresql/10/main/pg_hba.conf
sudo cp "$REFUGE_PATH/setup/pg_hba.conf" $pg_hba
sudo chown postgres:postgres $pg_hba
sudo chmod 640 $pg_hba
sudo -u postgres psql -c 'select pg_reload_conf();' postgres

# Creating postres user
if ! sudo -u postgres psql -c 'SELECT rolname FROM pg_roles;' postgres | grep vagrant; then
  echo 'Creating vagrant postgres user...'
  sudo -u postgres createuser vagrant --createdb  --superuser
fi

# Seed db
echo 'Seeding db...'
bundle exec rake db:setup
