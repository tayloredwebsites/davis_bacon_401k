#require "log4r"

class AccountController < ApplicationController
	before_filter :login_required, :only => [ :welcome ]

  layout 'application'

  # def initialize
  #   #@@log = Log4r::Logger.new('App::AccountController')
  # end

  def login
    session[:user_id] = session[:login] = nil
    if !request.get?
      Rails.logger.debug("*** params")
      @current_user = User.authenticate(params['user_login'], params['user_password'])
      if @current_user
        session[:user_id] = @current_user.id
        @login = session[:login] = @current_user.login
        flash['notice']  = "Login successful"
		    logger.debug("logger: Login successful, redirect_to welcome")
		    #@@log.debug("@@log: Login successful, redirect_to welcome")
        redirect_to :action => "welcome"
      else
        flash.now['notice']  = "Login unsuccessful"
        # @login = params[:user_login]
		    @message  = "Login unsuccessful"
      end
    else
      Rails.logger.debug("logger: login get form display")
      # render "login", layout: 'application'
    end
  end

  def signup
    usercount = User.count
    #if @session[:user].nil? || usercount != 0
    if usercount != 0
      redirect_to :action => "login"
    else
      #standard code of signup...
      @user = User.new(params[:user])
	    if request.post? and @user.save
        Rails.logger.debug("*** signup @user: #{@user.inspect}")
        # @current_user = User.authenticate(params['user_login'], params['user_password'])
        @current_user = @user
        Rails.logger.debug("*** signup @current_user: #{@current_user.inspect}")
        session[:user_id] = @current_user.id
        @login = session[:login] = @current_user.login
	      flash['notice']  = "Signup successful"
	      # todo note not redirecting to @request.session[:return_to] in tests !!!!
	      #redirect_back_or :action => "welcome"
	      redirect_to( :action => 'welcome')
	    else
		    logger.error("logger: signup not posted, or got error")
		    #@@log.error("@@log: signup not posted, or got error")
	    end
	  end
  end

  def logout
    session[:user_id] = nil
  end

  def welcome
    logger.debug("logger: in account_controller.welcome")
    Rails.logger.debug("*** current_user: #{current_user.inspect}")
    #@@log.debug("@@log: in account_controller.welcome")
  end

end
