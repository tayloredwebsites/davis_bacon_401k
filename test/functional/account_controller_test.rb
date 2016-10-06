require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Set salt to 'tayloredbenefits' because thats what the fixtures and controller assume.
User.salt = 'tayloredbenefits'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = AccountController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
    @all_users = User.find(:all, :order => 'login')
  end

  def test_auth_bob
    @request.session[:return_to] = "/bogus/location"
    post :login, :user_login => "bob", :user_password => "bobs_secure_password"
    assert_not_nil :user
    assert_equal 'bob', @request.session[:user].login
    assert_equal 'bob', @response.session[:user].login
  end

  def test_unauth_bob
    @request.session[:return_to] = "/bogus/location"
    post :login, :user_login => "bob", :user_password => "test"
    assert_equal nil, @request.session[:user]
    assert_equal nil, @response.session[:user]
    assert_response :success
    assert_equal flash.now['notice'], "Login unsuccessful"
  end

  def test_signup
    User.all.each do |u|
      u.deactivate if u.deactivated == 0
  		u.destroy
  	end
    # signup only allowed if no current users !!!
  	assert_equal User.count, 0
    @request.session[:return_to] = "/bogus/location"
    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    # assert_session_has :user
    assert_not_equal nil, @request.session[:user]
    assert_not_equal nil, @response.session[:user]
    assert_redirected_to :action => 'welcome'
    assert_equal User.count, 1

  end

  def test_bad_signup
  	assert_equal User.count, 6
    @request.session[:return_to] = "/bogus/location"
    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_equal false, @request.session[:user].present?
    assert_equal nil, assigns(:user)
    assert_redirected_to :action => 'login'
    @request.session[:return_to] = "/bogus/location"
    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "wrong" }
    assert_equal false, @request.session[:user].present?
    assert_equal nil, assigns(:user)
    assert_response :redirect
    assert_redirected_to :action => 'login'
    #assert_success

    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_equal false, @request.session[:user].present?
    assert_equal nil, assigns(:user)
    assert_response :redirect
    assert_redirected_to :action => 'login'
  end

  def test_signup_with_users
  	assert User.count > 0
    @request.session[:return_to] = "/bogus/location"
    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    # assert_session_has_no :user
    # assert_nil @request.session[:user]
    assert_equal nil, @request.session[:user]
    assert_equal nil, @response.session[:user]
    assert_response :redirect
    assert_redirected_to :action => 'login'
  end

  def test_invalid_login
    post :login, :user_login => "bob", :user_password => "not_correct"
    # assert_session_has_no :user
    assert_equal nil, @request.session[:user]
    assert_equal nil, @response.session[:user]
    assert_response :success
    assert_equal flash.now['notice'], "Login unsuccessful"
  end

  def test_login_logoff

    post :login, :user_login => "bob", :user_password => "bobs_secure_password"
    # assert_session_has :user
    assert_equal 'bob', @request.session[:user].login
    assert_equal 'bob', @response.session[:user].login
    assert_response :redirect
    assert_redirected_to :action => 'welcome'
    assert_equal flash.now['notice'], "Login successful"

    get :logout
    # assert_session_has_no :user
    assert_equal nil, @request.session[:user]
    assert_equal nil, @response.session[:user]
    assert_response :success

  end


end
