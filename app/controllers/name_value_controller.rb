class NameValueController < ApplicationController

	# ensure logged in before using, except in test mode
	if ENV['RAILS_ENV'] != 'test'
		before_filter :login_required, :login_as_supervisor
	end

	def login_as_supervisor
		@test_user = response.session[:user]
    if @test_user == nil
    	flash[:notice] = 'Error - must be logged in to maintain name_values'
    else
    	if @test_user.supervisor != 1
	    	flash[:notice] = 'Error - must be supervisor to maintain name_values'
	    end
	  end # @test_user == nil
	end # login_as_supervisor

	def accounting_month
  	@errs = []
		@name_value = NameValue.new
  	@select_month = @name_value.cur_month = NameValue.get_accounting_month
  	@select_year = @name_value.cur_year = NameValue.get_accounting_year
  	if request.get?
	  	params['select_month'] = @select_month
	  	params['select_year'] = @select_year
    	flash[:notice] = ''
  	else
  		@sel_month = params[:select_month]
  		logger.debug("@sel_month="+@sel_month)
  		@sel_year = params[:select_year]
  		logger.debug("@sel_year="+@sel_year)
		  if @sel_month && !@sel_month.blank? && @sel_year && !@sel_year.blank?
		    @err = NameValue.set_accounting_month(@sel_year, @sel_month)
		    if @err
		      flash[:notice] = @err
		      @errs.push(@err)
		    else
			    flash[:notice] = ''
		    end
		  else
		  	flash[:notice] = 'post to controller has nil/blank year or month'
		  	@errs.push('post to controller has nil/blank year or month')
		  end
    	params['select_month'] = @select_month = NameValue.get_accounting_month
    	params['select_year'] = @select_year = NameValue.get_accounting_year
	  end	# request.get?
	end

  def create
  	if request.get?
    	redirect_to :action => 'new'
  	else
	    @name_value = NameValue.new(params[:name_value])
	    if @name_value.save
	      flash[:notice] = 'NameValue was successfully created.'
	      redirect_to :action => 'view', :id => @name_value
	    else
		    flash[:notice] = 'Error - NameValue was not created'	#todo params[:name_value].val_name ???
	      render :action => 'new'
	    end
	  end	# request.get?
  end

  def edit
    @name_value = NameValue.find(params[:id])
  end

  def index
    list
    render :action => 'list'
  end

  def list
    @name_value_pages = @name_values = NameValue.order('val_name').
      paginate(:page => params[:page], :per_page => 10)

  end

  def new
    @name_value = NameValue.new
  end

  def show
    @name_value = NameValue.find(params[:id])
  end

  def view
    show
    render :action => 'show'
  end

  def update
  	if request.get?
    	redirect_to :action => 'list'
  	else
	    @name_value = NameValue.find(params[:id])
	    if @name_value.update_attributes(params[:name_value])
	      redirect_to :action => 'show', :id => @name_value
	    else
		    flash[:notice] = 'Error - NameValue was not updated'	#todo params[:name_value].val_name ???
	      render :action => 'edit'
	    end
	  end	# request.get?
  end

end
