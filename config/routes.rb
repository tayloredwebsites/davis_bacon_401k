ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  #map.connect '', :controller => 'account', :action => 'welcome', :target => 'benefits'
  map.root :controller => 'account', :action => 'welcome'


  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # accounting_month page
  map.connect 'accounting_month/:select_year/:select_month',
  		:controller => 'name_value',
  		:action => 'accounting_month',
  		:select_year => nil,
  		:select_month => nil,
  		:requirements => {
  			:select_year => /20\d\d/,
  			:select_month => /1?\d/
  		}

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
