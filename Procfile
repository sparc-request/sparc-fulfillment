web: bundle exec puma -C config/puma.rb
worker: bundle exec rake jobs:work
faye: rackup faye.ru -s Puma -E production
