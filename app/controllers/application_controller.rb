class ApplicationController < ActionController::Base
  protect_from_forgery
  include LoginSystem
  #model :user

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '6de586aa4f8629b8ddf9ded99f46fa17'

  #before_filter :set_user

  #require 'login_system'
  #require "will_paginate"

  protected
    def set_user
      @user = User.find(session[:id]) if @user.nil? && session[:id]
      debugger
    end

    def login_required
      logger.debug("login_required")
      return true if session[:user]
      access_denied
      return false
    end

    def access_denied
      logger.debug("access_denied")
      session[:return_to] = request.url
      flash[:error] = 'Oops. You need to login before you can view that page.'
      redirect_to :controller => 'account', :action => 'login'
    end

  def redirect_back_or(path)
    redirect_to :back
    rescue ActionController::RedirectBackError
    redirect_to path
  end
end