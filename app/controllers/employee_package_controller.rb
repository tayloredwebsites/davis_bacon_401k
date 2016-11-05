class EmployeePackageController < ApplicationController

	# ensure logged in before using, except in test mode
	if ENV['RAILS_ENV'] != 'test'
		before_filter :login_required
	end

  def create
  	flash[:notice] = ''
  	#if request.get?
    #	redirect_to :action => 'new'
  	#else
  	if params[:employee_package]
	    @employee_package = EmployeePackage.new(params[:employee_package])
    	if params[:id] && !@employee_package.id
    		@employee_package.id = params[:id]
    	end
    	if !@employee_package.employee_id
			  flash[:notice] = 'Error - need employee id to create employee package'
		  	redirect_to :controller => 'employee', :action=> 'list'
		  elsif @employee_package.is_package_duplicate
			  flash[:notice] = 'Error - duplicate package for employee and effective month/year'
			  redirect_to :controller => 'employee', :action=> 'edit', :id => @employee_package.employee_id
		  else
		  	@employee = Employee.find(@employee_package.employee_id)
		    if @employee_package.audit_save
		      flash[:notice] = 'EmployeePackage was successfully created.'
		      #redirect_to :action => 'view', :id => @employee_package
		  		redirect_to :controller => 'employee', :action=> 'edit', :id => @employee_package.employee_id
		    else
			    if !@employee_package.errors.empty?
			    	flash[:notice] = 'Error - Create error, ' + @employee_package.errors.full_messages.join("; ")
			    end
		      render :action => 'new'
		    end
		  end
      else
        flash[:notice] = 'Error - create error - missing employee_package parameter'
      end
	  #end	# request.get?
  end

  def destroy
  	flash[:notice] = ''
  	#if request.get?
    #	redirect_to :action => 'list'
  	#else
	    @employee_package = EmployeePackage.find(params[:id])
	  	@employee = Employee.find(@employee_package.employee_id)
    	@emp_name = @employee.emp_id.to_s + " " + @employee.last_name + ", " + @employee.first_name + " " + @employee.mi
	    #@all_packages = EmployeePackage.find(:all, :conditions => ["employee_id = ?", params[:employee_package_employee_id]])
	    #@pkg_count = @all_packages.count
	    #davet 2010_11_19 removed ? from count string argument
	    @pkg_count = EmployeePackage.where("employee_id = ?", @employee_package.employee_id).count
	    if @pkg_count > 1
		    @employee_package.destroy
		    if !@employee_package.errors.empty?
		    	flash[:notice] = 'Error - Destroy error, ' + @employee_package.errors.full_messages.join("; ")
		    end
	    	flash[:notice] = 'Benefits Package (effective ' + @employee_package.eff_month.to_s + '/' + @employee_package.eff_year.to_s + ') for ' + @emp_name + ' deleted'
	    elsif @pkg_count < 1
	    	flash[:notice] = 'Error - no Benefits Packages for ' + @emp_name
	    else
	    	flash[:notice] = 'Error - cannot delete the only Benefits Package for ' + @emp_name
		  end
	    #redirect_to :action => 'list'
		  redirect_back_or :controller => 'employee',
		  	:action => "show",
		  	:id => @employee_package.employee_id
	  #end	# request.get?
  end

  def edit
  	flash[:notice] = ''
  	@old_employee_package = nil
	  if params[:id]
	  	@employee_package = EmployeePackage.find(params[:id])
	  	@employee = Employee.find(@employee_package.employee_id)
	  else
		  flash[:notice] = 'Error - need employee package id to edit employee package'
	  	redirect_to :controller => 'employee', :action=> 'list'
	  end
    @employee_package = EmployeePackage.find(params[:id])
#    if @employee_package.has_deposits
#    	@old_employee_package = @employee_package.clone
#    	@old_employee_package.id = nil
#    	@employee_package = EmployeePackage.new :employee_id => @employee_package.employee_id, :eff_month => @employee_package.eff_month, :eff_year => @employee_package.eff_year
#    	@employee_package.set_defaults
#    #	flash[:notice] = 'Debugging - creating new package for employee ' + @employee_package.employee_id.to_s + ', package = ' + params[:id]
#    #else
#    #	flash[:notice] = 'Debugging - use existing package for employee ' + @employee_package.employee_id.to_s + ', package = ' + params[:id]
#    end
    @employee_package
  end

  def index
    list
    render :controller => 'employee', :action => 'list'
  end

  def list
    # note this is not used, as it is a listing of all packages without selecting or showing employee
    flash[:notice] = ''
    @employee_packages = @employee_package_pages = EmployeePackage.
      where("eff_year >= ?", NameValue.get_val('start_year').to_i).
      order('eff_year DESC, eff_month DESC').
      paginate(:page => params[:page], :per_page => 10)
  end

  def new
  	flash[:notice] = ''
	  if params[:employee]
	  	@employee = Employee.find(params[:employee])
		  @employee_package = EmployeePackage.new :employee_id => params[:employee]
	  elsif params[:employee_id]
	  	@employee = Employee.find(params[:employee_id])
		  @employee_package = EmployeePackage.new :employee_id => params[:employee_id]
	  else
		  flash[:notice] = 'Error - need employee id to create employee package'
	  	redirect_to :controller => 'employee', :action=> 'list'
	  end
  end

  def show
  	flash[:notice] = ''
    @employee_package = EmployeePackage.find(params[:id])
	  @employee = Employee.find(@employee_package.employee_id)
  end

  def view
    show
    render :action => 'show'
  end

  def update
  	flash[:notice] = ''
  	if request.get?
    	redirect_to :action => 'list'
  	else
    	if params[:id]
    	    @employee_package = EmployeePackage.find(params[:id])
		  	# first deactivate original package if necessary (not in transaction)
		  	if @employee_package.has_deposits
		  		@emp_pkg_old = EmployeePackage.find(params[:id])
		  		@emp_pkg_old.deactivated = 1
		  		@isok = @emp_pkg_old.audit_save
#breakpoint
		  		@employee_package = EmployeePackage.new(params[:employee_package])
		  		@employee_package.deactivated = 0
		  	end
		  	# then update
    	  	@employee = Employee.find(@employee_package.employee_id)
    	    if @employee_package.audit_update_attributes(params[:employee_package])
    	      #redirect_to :action => 'show', :id => @employee_package
    		  	redirect_back_or :controller => 'employee',
    		  		:action => "view",
    		  		:id => @employee_package.employee_id
    	    else
    		    if !@employee_package.errors.empty?
    		    	flash[:notice] = 'Error - Update error, ' + @employee_package.errors.full_messages.join("; ")
    		    #else
    		    #	flash[:notice] = 'Error - Update error.'
    		    end
    	      render :action => 'edit'
    	    end
    	else
    	    @employee_package = EmployeePackage.new(params[:employee_package])
        	if !@employee_package.employee_id
    			flash[:notice] = 'Error - need employee id to create updated employee package'
    		  	redirect_to :controller => 'employee', :action=> 'list'
    		elsif @employee_package.is_package_duplicate
    			flash[:notice] = 'Error - package exists for effective month already'
    		  	redirect_to :controller => 'employee', :action=> 'list'
    		  else
    		  	@employee = Employee.find(@employee_package.employee_id)
    		    if @employee_package.audit_save
    		      flash[:notice] = 'updated employee package was successfully created.'
    		      #redirect_to :action => 'view', :id => @employee_package
    		  		redirect_to :controller => 'employee', :action=> 'edit', :id => @employee_package.employee_id
    		    else
    			    if !@employee_package.errors.empty?
    			    	flash[:notice] = 'Error - Create error, ' + @employee_package.errors.full_messages.join("; ")
    			    end
    		      render :action => 'list'
    		    end
    		  end
        end
	end	# request.get?
  end

  def deactivate
    flash[:notice] = ''
    if params[:id]
      @employee_package = EmployeePackage.find(params[:id])
      @employee = Employee.find(@employee_package.employee_id)
      if @employee_package.audit_deactivate
        #redirect_to :action => 'show', :id => @employee_package
        redirect_back_or :controller => 'employee',
          :action => "view",
          :id => @employee_package.employee_id
      else
        if !@employee_package.errors.empty?
          flash[:notice] = 'Error - Update error, ' + @employee_package.errors.full_messages.join("; ")
          #else
          # flash[:notice] = 'Error - Update error.'
        end
        render :action => 'edit'
      end
    end
  end

  def reactivate
  	flash[:notice] = ''
    if params[:id]
      @employee_package = EmployeePackage.find(params[:id])
      @employee = Employee.find(@employee_package.employee_id)
      if @employee_package.audit_reactivate
        #redirect_to :action => 'show', :id => @employee_package
        redirect_back_or :controller => 'employee',
          :action => "view",
          :id => @employee_package.employee_id
      else
        if !@employee_package.errors.empty?
          flash[:notice] = 'Error - Update error, ' + @employee_package.errors.full_messages.join("; ")
          #else
          #	flash[:notice] = 'Error - Update error.'
        end
        render :action => 'edit'
      end
    end
  end

end
