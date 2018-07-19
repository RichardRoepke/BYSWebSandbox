Rails.application.routes.draw do
  root 'static_pages#main'
  get  '/utility',   to: 'services#utility'
  get  '/availability', to: 'services#availability'
end
