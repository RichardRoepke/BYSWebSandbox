Rails.application.routes.draw do
  root 'static_pages#main'
  get  '/utility',   to: 'services#utility'
end
