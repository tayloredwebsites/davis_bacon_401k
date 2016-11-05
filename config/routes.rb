DavisBacon401k::Application.routes.draw do

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

  match 'account/login', to: 'account#login', via: [:get, :post]
  match 'account/logout', to: 'account#logout', via: [:get, :post]
  get 'account/list', to: 'account#list'
  post 'account/create', to: 'account#create'
  resources :account do |r|
    member do
      post :login
      post :signup
    end
  end

  get 'employee/list', to: 'employee#list'
  post 'employee/create', to: 'employee#create'
  resources :employee do
    member do
      get :deactivate
      get :reactivate
    end
    collection do
      get :list
      get :benefits_list
      get :report_list
    end
  end

  get 'employee_package/list', to: 'employee_package#list'
  post 'employee_package/create', to: 'employee_package#create'
  resources :employee_package do
    member do
      get :deactivate
      get :reactivate
    end
  end

  post 'employee_benefit/create', to: 'employee_benefit#create'
  post 'employee_benefit/:id', to: 'employee_benefit#update'
  get 'employee_benefit/edit', to: 'employee_benefit#edit'
  get 'employee_benefit/list', to: 'employee_benefit#list'
  get 'employee_benefit/make_cur_deposit', to: 'employee_benefit#make_cur_deposit'
  resources :employee_benefit

  get 'users/list', to: 'users#list'
  post 'users/create', to: 'users#create'
  resources :users do
    member do
      get :deactivate
      get :reactivate
    end
  end

  get '/report/employee_master_report', to: 'report#employee_master_report'
  get '/report/entry_recon_options', to: 'report#entry_recon_options'
  post '/report/entry_recon_report', to: 'report#entry_recon_report'
  get '/report/deposit_recon_options', to: 'report#deposit_recon_options'
  post '/report/deposit_recon_report', to: 'report#deposit_recon_report'
  get '/report/monthly_benefits_options', to: 'report#monthly_benefits_options'
  post '/report/monthly_benefits_report', to: 'report#monthly_benefits_report'

  get 'help/help', to: 'help#help'
  get 'help/current_month', to: 'help#current_month'
  get 'help/employees', to: 'help#employees'
  get 'help/benefits', to: 'help#benefits'
  get 'help/reports', to: 'help#reports'
  get 'help/users', to: 'help#users'
  get 'help/login', to: 'help#login'

  # Old Rails 2 Route
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
  match 'accounting_month' => 'name_value#accounting_month', via: [:get, :post]
  match 'name_value/accounting_month' => 'name_value#accounting_month', via: [:get, :post]
  get 'accounting_month/:select_year/:select_month' => 'name_value#accounting_month',
    constraints: {select_year: /2\d\d\d/, select_month: /1?\d/}



  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'account#welcome'

  # See how all your routes lay out with "rake routes"

  # # Old Rails 2 Route
  # # # Install the default route as the lowest priority.
  # # connect ':controller/:action/:id'
  # # connect ':controller/:action/:id.:format'

  # # This is a legacy wild controller route that's not recommended for RESTful applications.
  # # Note: This route will make all actions in every controller accessible via GET requests.
  # get ':controller(/:action(/:id))(.:format)'
end
