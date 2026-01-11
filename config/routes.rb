Rails.application.routes.draw do
  root 'home#index'
  post '/', to: 'home#index' # POST 방식도 허용하여 검색 반응성 향상
end