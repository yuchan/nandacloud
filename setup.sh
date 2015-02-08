#!/bin/sh

PRJ=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo $PRJ

bundle install

cd $PRJ/app && bundle install
cd $PRJ/chef && bundle exec berks vendor cookbooks

cd $PRJ

echo "setup done!"

