#require "log4r"

class AccountController < ApplicationController
	before_filter :login_required, :only => [ :welcome ]

  #layout  'scaffold'


  def initialize
    #@@log = Log4r::Logger.new('App::AccountController')
  end

  def login
    #flash.now['login test']
    if !request.get?
    #case @request.method
    #  when :post
      if session[:user] = User.authenticate(params['user_login'], params['user_password'])

        flash['notice']  = "Login successful"
		    logger.debug("logger: Login successful, redirect_to welcome")
		    #@@log.debug("@@log: Login successful, redirect_to welcome")
        redirect_to :action => "welcome"
      else
        flash.now['notice']  = "Login unsuccessful"

        @login = params[:user_login]
		    @message  = "Login unsuccessful"
      end
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
	      session[:user] = User.authenticate(@user.login, params[:user][:password])
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
    session[:user] = nil
  end

  def welcome
    logger.debug("logger: in account_controller.welcome")
    #@@log.debug("@@log: in account_controller.welcome")
  end

end
