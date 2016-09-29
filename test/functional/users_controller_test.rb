require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'
require 'account_controller'

# Set salt to 'tayloredbenefits' because thats what the fixtures and controller assume.
User.salt = 'tayloredbenefits'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    #@request.host = "localhost"	# ??
  end

  def test_create_1
    num_users = User.count

    post :create, :user => {}

    assert_response :success
    assert_template 'new'

    assert_equal num_users, User.count
  end

  def test_create_2
    num_users = User.count

    post :create, :user => {:login => "bobnew", :password => "bobs_secure_password"}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_users + 1, User.count
  end

  def test_deactivate_1
    assert_not_nil User.find(1000001)

    post :deactivate, :id => 1000001
    assert_response :redirect
    assert_redirected_to :action => 'list'

    @test_user = User.find(1000001)
    assert_not_nil @test_user
    assert_equal @test_user.deactivated,1
  end

  def test_destroy_1
    assert_not_nil User.find(1000001)

    post :destroy, :id => 1000001
    assert_response :redirect
    assert_redirected_to :action => 'list'

    #assert_raise(ActiveRecord::RecordNotFound) {
    #  User.find(1000001)
    #}

    assert_not_nil User.find(1000001)
  end

  def test_destroy_2
    assert_not_nil User.find(1000001)

    post :deactivate, :id => 1000001
    assert_response :redirect
    assert_redirected_to :action => 'list'

    @test_user = User.find(1000001)
    assert_not_nil @test_user
    assert_equal @test_user.deactivated,1

    post :destroy, :id => 1000001
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(1000001)
    }

  end

  def test_edit
    get :edit, :id => 1000001

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:users)
  end

  def test_show
    get :show, :id => 1000001

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user)
  end

  def test_update
    get :edit, :id => 1000001

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
    assert_equal assigns(:user).supervisor,0

    post :update, :id => 1000001, :user => {:supervisor => 1}
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1000001
    #assert_template 'show'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
    assert_equal assigns(:user).supervisor,1

    @test_user = User.find(1000001)
    assert_not_nil @test_user
    assert_equal @test_user.supervisor,1

  end


end
