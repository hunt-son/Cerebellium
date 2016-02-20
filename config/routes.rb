Rails.application.routes.draw do
  root 'pages#home'
  post 'getaway/index' => 'getaway#index'
end
