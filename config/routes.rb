Rails.application.routes.draw do
  root 'static_pages#main'
  get  '/utility',   to: 'services#utility'
  get  '/availability', to: 'services#availability'
  get  '/calculate', to: 'services#calculate'
  get  '/reservationhold', to: 'services#res_hold'
  get  '/reservationconfirm', to: 'services#res_confirm'
  get  '/siteusage', to: 'services#site_usage'
  get  '/reservationcreate', to: 'services#res_create'
  get  '/sitecancel', to: 'services#site_cancel'
  get  '/reservationreverse', to: 'services#res_reverse'
end
