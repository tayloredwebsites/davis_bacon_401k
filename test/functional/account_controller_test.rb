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
    assert_session_has :user

		@test_bob = @response.session[:user]
    assert_not_nil @test_bob
    assert_equal 'bob', @test_bob.login

    # assert_redirect_url "/bogus/location"
  end

  def test_unauth_bob
    @request.session[:return_to] = "/bogus/location"

    post :login, :user_login => "bob", :user_password => "test"
    #assert_nil :user
    assert_session_has_no :user
    #assert_redirected_to :action => 'welcome'

  end

  def test_signup

  	for @u in @all_users
  		@u.deactivate
  		@u.destroy
	  	#assert @u.errors.count == 0
  	end

  	assert User.count == 0

    #@request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_session_has :user

    #assert_redirect_url "/bogus/location"
    assert_redirected_to :action => 'welcome'
  end

  def test_bad_signup

  	for @u in @all_users
  		@u.deactivate
  		@u.destroy
	  	#assert @u.errors.count == 0
  	end

  	assert User.count == 0

    @request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_session_has :user
    @newbob = @request.session[:user]
    assert_not_nil @newbob
    assert_equal @newbob.login, 'newbob'
    #assert_redirect_url "/bogus/location"
    assert_redirected_to :action => 'welcome'

    @request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "wrong" }
    assert_invalid_column_on_record "user", :password
    assert_response :redirect
    assert_redirected_to :action => 'login'
    #assert_success

    post :signup, :user => { :login => "yo", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_invalid_column_on_record "user", :login
    assert_response :redirect
    assert_redirected_to :action => 'login'
    #assert_success

  end

  def test_signup_with_users

  	assert User.count > 0

    @request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :login => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_session_has_no :user
    assert_nil @request.session[:user]

    assert_redirected_to :action => 'login'
  end

  def test_invalid_login
    post :login, :user_login => "bob", :user_password => "not_correct"

    assert_session_has_no :user

    assert_template_has "login"
  end

  def test_login_logoff

    post :login, :user_login => "bob", :user_password => "bobs_secure_password"
    assert_session_has :user

    get :logout
    assert_session_has_no :user

  end


end
