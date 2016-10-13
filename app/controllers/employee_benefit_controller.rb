class EmployeeBenefitController < ApplicationController

	# ensure logged in before using, except in test mode
	if ENV['RAILS_ENV'] != 'test'
		before_filter :login_required
	end

  def create
  	if request.get?
    	redirect_to :action => 'new'
  	else
	    @employee_benefit = EmployeeBenefit.new(params[:employee_benefit])
    	if params[:id] && !@employee_benefit.id
    		@employee_benefit.id = params[:id]
    	end
    	if !@employee_benefit.employee_id
			  flash[:notice] = 'Error - need employee id to create employee benefit'
		  	redirect_to :controller => 'employee', :action=> 'benefits_list'
		  else
		    for @bene_dep_key in params.keys
		      process_pending_checks(@bene_dep_key)
		    end
		  	@employee = Employee.find(@employee_benefit.employee_id)
		    if @employee_benefit.save
		      logger.debug('EmployeeBenefit was successfully created.')
		      flash[:notice] = 'EmployeeBenefit was successfully created.'
		      #redirect_to :action => 'view', :id => @employee_benefit
		  		redirect_to :controller => 'employee_benefit', :action=> 'edit', :id => @employee_benefit.id
		    else
			    if !@employee_benefit.errors.empty?
			    	logger.debug('Error - Create error, ' + @employee_benefit.errors.full_messages.join("; ") )
			    	flash[:notice] = 'Error - Create error, ' + @employee_benefit.errors.full_messages.join("; ")
			    else
				    logger.debug('Error - EmployeeBenefit was not created')
				    flash[:notice] = 'Error - EmployeeBenefit was not created'
			    end
		      render :action => 'edit'
		    end
		  end
	  end	# request.get?
  end

  def destroy
  	#if request.get?
    #	redirect_to :action => 'list'
  	#else
    @employee_benefit = EmployeeBenefit.find(params[:id])
  	@employee = Employee.find(@employee_benefit.employee_id)
  	@emp_name = @employee.emp_id.to_s + " " + @employee.last_name + ", " + @employee.first_name + " " + @employee.mi
    @is_deposited = false
    if EmployeeBenefit.employee_package_id != nil
    	if EmployeeBenefit.employee_package_id > 0
    		@is_deposited = true
    	end
    end
    if !@is_deposited
	    @employee_benefit.destroy
	    if !@employee_benefit.errors.empty?
	    	flash[:notice] = 'Error - Destroy error, ' + @employee_benefit.errors.full_messages.join("; ")
	    else
	    	flash[:notice] = 'Benefits Package (effective ' + @employee_benefit.eff_month.to_s + '/' + @employee_benefit.eff_year.to_s + ') for ' + @emp_name + ' deleted'
	    end
    else
    	flash[:notice] = 'Error - cannot delete deposited benefits record'
	  end
	  redirect_to :action => 'list_by_emp', :employee => @employee
	  #end	# request.get?
  end

  def edit
	  if params[:id]
	  	@employee_benefit = EmployeeBenefit.find(params[:id])
	  	if @employee_benefit
			  @employee_package = @employee_benefit.current_package
		  	@employee = Employee.find(@employee_benefit.employee_id)
		  end
		end
		if @employee == nil
			if params[:employee_id]
	  		@employee = Employee.find(params[:employee_id])
	  	elsif params[:employee]
	  		@employee = Employee.find(params[:employee])
	  	end
	  end
  	if @employee != nil
  		@employee_benefit = @employee.cur_benefit
  	else
	    flash[:notice] = 'Error - Cannot create Benefit without employee specified'
		  redirect_to :controller => 'employee', :action => 'benefits_list'
  	end
		if @employee_benefit != nil && @employee_benefit.deposited_at == nil
			# found benefit, and it has not been deposited yet - can edit
			@employee_package = EmployeePackage.find(@employee_benefit.employee_package_id)
			if @employee_package == nil || @employee_package.deactivated != 0
				@employee_package = @employee.emp_latest_pkg
	    	#flash[:notice] = 'Debugging - Created package from emp_latest_pkg - ' + @employee_package.id
			end
		else
			@employee_benefit = EmployeeBenefit.new :employee_id => @employee.id
			@employee_package = @employee.emp_latest_pkg
	    #flash[:notice] = 'Debugging - Created benefit, and package from emp_latest_pkg - ' + @employee_package.id.to_s
		end
		if @employee_package == nil && @employee != nil
		  flash[:notice] = 'Error - Missing Employee Package'
		  redirect_to :controller => 'employee', :action => 'edit', :id => @employee.id
		end
		#@employee_package = EmployeePackage.new :employee_id => @employee.id
  end


  def index
    list
    render :controller => 'employee_benefit', :action => 'list'
  end

  def list
		if @employee == nil
			if params[:employee_id]
	  		@employee = Employee.find(params[:employee_id])
	  	elsif params[:employee]
	  		@employee = Employee.find(params[:employee])
	  	end
	  end
    @employee_benefits = EmployeeBenefit.paginate(:all,
  		:page => params[:page],
  		:per_page => 10,
  		:order => 'eff_year, eff_month',
  		:conditions => ["eff_year >= ? and employee_id = ?", NameValue.get_val('start_year'), params[:employee_id] ]
  	)
  end

  def show
    @employee_benefit = EmployeeBenefit.find(params[:id])
  end

  def view
    show
    render :action => 'show'
  end

  def update
  	if request.get?
    	redirect_to :action => 'list'
  	else
		  if params[:id]
		    @acc_mo = NameValue.get_val("accounting_month")
		    @acc_yr = NameValue.get_val("accounting_year")
		    for @bene_dep_key in params.keys
		      process_pending_checks (@bene_dep_key)
            end
		    @employee_benefit = EmployeeBenefit.find(params[:id])
		  	@employee = Employee.find(@employee_benefit.employee_id)
		    if @employee_benefit.update_attributes(params[:employee_benefit])
		      #redirect_to :action => 'show', :id => @employee_benefit
			  	#redirect_back_or :controller => 'employee_benefit',
			  	#	:action => "edit",
			  	#	:id => @employee_benefit.employee_id
		  		redirect_to :action => 'edit', :employee => @employee.id
		      #render :action => 'edit'
		    else
			    if !@employee_benefit.errors.empty?
			    	flash[:notice] = 'Error - Update error, ' + @employee_benefit.errors.full_messages.join("; ")
			    #else
			    #	flash[:notice] = 'Error - Update error.'
			    end
		  		redirect_to :action => 'edit', :employee => @employee.id
		      #render :action => 'edit'
		    end
		  else
		  	redirect_back_or :controller => 'employee',
		  		:action => "benefits_list"
		  end # if params[:id]
	  end	# request.get?
  end

  def process_pending_checks (bene_dep_key)
    if bene_dep_key[0,8] == 'dep_flag'
      @acc_mo = NameValue.get_val("accounting_month")
      @acc_yr = NameValue.get_val("accounting_year")
      @bene_dep_id = bene_dep_key[8,2]
      @emp_bene_dep = EmployeeBenefit.find(@bene_dep_id)
      if eval(params[bene_dep_key])
        if @emp_bene_dep.dep_eff_month.to_s != @acc_mo ||
          @emp_bene_dep.dep_eff_year.to_s != @acc_yr
          @emp_bene_dep.dep_eff_month = @acc_mo.to_i
          @emp_bene_dep.dep_eff_year = @acc_yr.to_i
          @emp_bene_dep.save
        end
      else
        if @emp_bene_dep.dep_eff_month.to_s == @acc_mo &&
          @emp_bene_dep.dep_eff_year.to_s == @acc_yr
          @emp_bene_dep.dep_eff_month = @emp_bene_dep.eff_month
          @emp_bene_dep.dep_eff_year = @emp_bene_dep.eff_year
          @emp_bene_dep.save
        end
      end
    end
  end

  def make_cur_deposit
  	EmployeeBenefit.make_cur_deposit
  	redirect_to :controller => 'employee', :action => 'benefits_list'
 	end

end
