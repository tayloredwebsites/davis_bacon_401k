class UsersController < ApplicationController

	# ensure user logged in before using, except in test mode
	if ENV['RAILS_ENV'] != 'test'
		before_filter :login_required
	end

  def create
  	if request.get?
	    flash[:notice] = 'Error - cannot use get to create'
    	redirect_to :action => 'new'
  	else
	    @user = User.new(params[:user])
	    if @user.save
	      flash[:notice] = 'User was successfully created.'
	      redirect_to :action => 'list'
	    else
	    	flash[:notice] = 'Error on create'
	      render :action => 'new'
	    end
	  end	# request.get?
  end

  def deactivate
  	#if request.get?
	  #  flash[:notice] = 'Error - cannot use get to deactivate'
    #	redirect_to :action => 'list'
  	#else
	    @user = User.find(params[:id])
	    if @user.update_attributes(:deactivated => 1)
	      flash[:notice] = 'User was successfully deactivated.'
	      redirect_to :action => 'list'
	    else
	    	flash[:notice] = 'Error on deactivate'
	      redirect_to :action => 'show', :id => @user
	    end
	  #end	# request.get?
  end

  def destroy
    @user = User.find(params[:id])
    if (@user.deactivated).to_s == '1'
    	@u_login = @user.login
	    @user.destroy
    	flash[:notice] = 'user ' + @u_login + ' deleted'
    else
	    flash[:notice] = 'Delete feature disabled, must deactivate user'
	  end
    redirect_to :action => 'list'
  end

  def edit
    @user = User.find(params[:id])
    @user["password"] = ''
  end

  def index
    list
    render :action => 'list'
  end

  def list
    @user_pages, @users = paginate(:users, :per_page => 10, :order_by => 'deactivated, login')
  end

  def new
    @user = User.new
  end

  def reactivate
    @user = User.find(params[:id])
    if @user.update_attributes(:deactivated => 0)
      flash[:notice] = 'User was successfully reactivated.'
      redirect_to :action => 'list'
    else
	    flash[:notice] = 'Error on reactivate'
      redirect_to :action => 'show', :id => @user
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def view
    show
    render :action => 'show'
  end

  def update
  	if request.get?
    	redirect_to :action => 'edit'
  	else
	    @user = User.find(params[:id])
	    if @user.update_attributes(params[:user])
	      flash[:notice] = 'User was successfully updated.'
	      redirect_to :action => 'show', :id => @user
	    else
	    	flash[:notice] = 'Error on update'
	      render :action => 'edit'
	    end
	  end	# request.get?
  end

end
