Rails.application.routes.draw do
  root 'static_pages#main'
  get  '/unit',   to: 'utility_services#unit'
  get  '/site',   to: 'utility_services#site'
  get  '/note',   to: 'utility_services#note'
end
