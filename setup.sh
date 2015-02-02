#!/bin/sh

PRJ=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo $PRJ

if [ ! -d "$HOME/.rbenv" ]; then
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

bundle install

cd $PRJ/app && bundle install
#cd $PRJ/chef && bundle exec berks vendor cookbooks

cd $PRJ

echo "setup done!"

