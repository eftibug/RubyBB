# RubyBB

A ruby bulletin board

## Installation

### Dependencies

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install libxslt1-dev memcached imagemagick libmysqld-dev nodejs curl git-core build-essential zlib1g-dev libssl-dev libreadline6-dev gem libyaml-dev

### Ruby 1.9.3 with RVM

    bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc
    source ~/.bashrc
    rvm pkg install openssl
    rvm install 1.9.3 --with-openssl-dir=$rvm_path/usr
    rmdir $rvm_path/usr/ssl/certs
    ln -s /etc/ssl/certs $rvm_path/usr/ssl

### Gems

    gem install mysql2
    gem install bundler
    gem install rails
    gem install nokogiri

### Fork, git clone and config

    cp config/database.yml.example config/database.yml
    cp config/private_pub.yml.example config/private_pub.yml
    cp config/initializers/devise.rb.example config/initializers/devise.rb
    cp config/initializers/secret_token.rb.example config/initializers/secret_token.rb

Configure them. Then:

    bundle install
    bundle exec rake db:create

### Setup and start elasticsearch

    curl -k -L -o elasticsearch-0.20.4.tar.gz http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.4.tar.gz
    tar -zxvf elasticsearch-0.20.4.tar.gz
    ./elasticsearch-0.20.4/bin/elasticsearch -f
    bundle exec rake environment tire:import CLASS='Message' FORCE=true

### Start faye

    bundle exec rackup private_pub.ru -s thin -E production

Keep `-E production` in development mode.

### Update everything

    git pull origin master
    bundle install
    bundle exec rake db:migrate
    bundle exec rake assets:clean assets:precompile

### Run specs

    RAILS_ENV=test bundle exec rake db:migrate
    bundle exec rspec spec/

You're ready!

## Start the server

    bundle exec rails s

## BSD 2-clause license

Copyright (c) 2012, Julien Grillot.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
