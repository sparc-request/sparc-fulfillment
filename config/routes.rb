Rails.application.routes.draw do
  mount API::Base => '/'
  root 'protocols#index'
end
