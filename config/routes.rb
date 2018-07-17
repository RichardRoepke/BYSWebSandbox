Rails.application.routes.draw do
  root 'static_pages#main'
  get  '/utility',   to: 'utility_services#utility'
end
