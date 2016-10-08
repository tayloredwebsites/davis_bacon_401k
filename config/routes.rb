DavisBacon401k::Application.routes.draw do

  # Old Rails 2 Routes:
  # # You can have the root of your site routed by hooking up ''
  # # -- just remember to delete public/index.html.
  # #map.connect '', :controller => 'account', :action => 'welcome', :target => 'benefits'
  # root :controller => 'account', :action => 'welcome'

  # # accounting_month page
  # connect 'accounting_month/:select_year/:select_month',
  #     :controller => 'name_value',
  #     :action => 'accounting_month',
  #     :select_year => nil,
  #     :select_month => nil,
  #     :requirements => {
  #       :select_year => /20\d\d/,
  #       :select_month => /1?\d/
  #     }
  match 'accounting_month' => 'name_value#accounting_month'
  match 'accounting_month/:select_year/:select_month' => 'name_value#accounting_month',
    constraints: {select_year: /2\d\d\d/, select_month: /1?\d/}

  # # Install the default route as the lowest priority.
  # connect ':controller/:action/:id'
  # connect ':controller/:action/:id.:format'


  # Rao;s 3 Routes:
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'account#welcome'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id))(.:format)'
end
