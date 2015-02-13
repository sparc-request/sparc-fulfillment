web: bundle exec puma -C config/puma.rb
worker: bundle exec rake jobs:work
faye: rackup faye.ru -s puma -E production -p 9292
