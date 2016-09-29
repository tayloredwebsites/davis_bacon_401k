class EmployeeController < ApplicationController

	# ensure logged in before using, except in test mode
	if ENV['RAILS_ENV'] != 'test'
		before_filter :login_required
	end

  def create
  	if request.get?
    	redirect_to :action => 'new'
  	else
	    @employee = Employee.new(params[:employee])
    	if params[:id] && !@employee.id
    		@employee.id = params[:id]
    	end
	    if @employee.save
	      flash[:notice] = 'Employee was successfully created.'
	      redirect_to :action => 'view', :id => @employee
	    else
	    	@empl_id = ''
		    if !@employee.errors.empty?
		    	flash[:notice] = 'Error - Employee ' + @empl_id + ' was not created, ' + @employee.errors.full_messages.join("; ")
		    end
	      render :action => 'new'
	    end
	  end	# request.get?
  end

  def deactivate
  	#if request.get?
	  #  flash[:notice] = 'Error - cannot use get to deactivate'
    #redirect_to :action => 'list'
  	#else
	    @employee = Employee.find(params[:id])
	    if @employee.update_attributes(:deactivated => 1)
	      flash[:notice] = 'Employee was successfully deactivated.'
	      redirect_to :action => 'list'
	    else
		    if !@employee.errors.empty?
		    	flash[:notice] = 'Error - Deactivate error, ' + @employee.errors.full_messages.join("; ")
		    end
	      redirect_to :action => 'show', :id => @employee
	    end
	  #end	# request.get?
  end

  def destroy
  	if request.get?
	    flash[:notice] = 'Error - cannot use get to deactivate'
  	else
	    @employee = Employee.find(params[:id])
	    if (@employee.deactivated).to_s == '1'
	    	@emp_name = @employee.last_name + ", " + @employee.first_name + " " + @employee.mi + ", "
		    @employee.destroy
	    	flash[:notice] = 'user ' + @emp_name + ' deleted'
	    else
		    flash[:notice] = 'Delete feature disabled, must deactivate user'
		  end
	  end	# request.get?
    redirect_to :action => 'list'
  end

  def edit
    @employee = Employee.find(params[:id])
  end

  def index
    list
    render :action => 'list'
  end

  def list
  	#@posts = Post.paginate :page => params[:page], :per_page => 50
    @employees = Employee.paginate(:all, :page => params[:page], :per_page => 10, :order => 'deactivated, emp_id')
  end

  def benefits_list
  	# this listing is for editing
    #@employee_pages, @employees = paginate(:employees, :per_page => 10, :conditions => 'deactivated = 0', :order_by => 'emp_id')
    @employees = Employee.find(:all,
    	:conditions => "deactivated = 0",
    	:order => 'emp_id'
    )
    @select_deposit = params[:select_deposit]
  end
  
  def report_list
  end

  def list_employee_packages
  	@emp_packages = EmployeePackage.find(:all,
  		:conditions => ["employee_id = ?", params[:id] ],
  		:order => 'eff_year DESC, eff_month DESC')
  end

  def new
    @employee = Employee.new
  end

  def reactivate
    @employee = Employee.find(params[:id])
    if @employee.update_attributes(:deactivated => 0)
      flash[:notice] = 'Employee was successfully reactivated.'
      redirect_to :action => 'list'
    else
	    if !@employee.errors.empty?
	    	flash[:notice] = 'Error - Reactivate error, ' + @employee.errors.full_messages.join("; ")
	    end
      redirect_to :action => 'show', :id => @employee
    end
  end

  def show
    @employee = Employee.find(params[:id])
  end

  def benefit_show
    @employee = Employee.find(params[:id])
    @employee_benefit = EmployeeBenefit.new :employee_id => params[:id]
    @employee_package = EmployeePackage.new :employee_id => params[:id]
    if @employee.cur_benefit
    	@employee_benefit = @employee.cur_benefit
    	if @employee_benefit.current_package
    		@employee_package = @employee_benefit.current_package
    	end
    end
  end

  def view
    show
    render :action => 'show'
  end

  def update
  	if request.get?
    	redirect_to :action => 'list'
  	else
	    @employee = Employee.find(params[:id])
	    if @employee.update_attributes(params[:employee])
	      redirect_to :action => 'show', :id => @employee
	    else
		    if !@employee.errors.empty?
		    	flash[:notice] = 'Error - Employee was not updated, ' + @employee.errors.full_messages.join("; ")
		    end
	      render :action => 'edit'
	    end
	  end	# request.get?
  end

end
