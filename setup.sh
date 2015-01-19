#!/bin/sh

PRJ=$PWD

echo $PRJ

bundle install

cd $PRJ/app && bundle install
cd $PRJ/chef && bundle exec berks vendor cookbooks

cd $PRJ

echo "setup done!"

