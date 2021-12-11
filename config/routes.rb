Rails.application.routes.draw do
  root 'static#index'
  resources :kube_namespace
  resources :kube_sealedsecrets
end
