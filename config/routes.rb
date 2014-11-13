Rails.application.routes.draw do
  mount CWFSPARC::API => '/'
  root 'protocols#index'
end
