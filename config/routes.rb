Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations]
  root 'static_pages#main'
  get  '/service', to: 'static_pages#service'
  get  '/misc', to: 'static_pages#misc'

  get  '/admin', to: 'admin_services#admin'
  get  '/admin/newuser', to: 'admin_services#new_user'
  get  '/admin/user/promote', to: 'admin/user#promote'
  get  '/admin/user/demote', to: 'admin/user#demote'

  get  '/utility', to: 'services#utility'
  get  '/availability', to: 'services#availability'
  get  '/calculate', to: 'services#calculate'
  get  '/reservationhold', to: 'services#res_hold'
  get  '/reservationconfirm', to: 'services#res_confirm'
  get  '/siteusage', to: 'services#site_usage'
  get  '/reservationcreate', to: 'services#res_create'
  get  '/sitecancel', to: 'services#site_cancel'
  get  '/reservationreverse', to: 'services#res_reverse'

  get  '/textparse', to: 'misc#text_parse'
  get  '/account', to: 'misc#account'

  namespace :admin do
    resources :user
  end
end
