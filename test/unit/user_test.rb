require 'test_helper'

User.salt = 'tayloredbenefits'

class UserTest < ActiveSupport::TestCase
  include NumberHandling

  fixtures :users

  def test_auth

    @test_bob = User.authenticate("bob", "bobs_secure_password")
    assert_not_nil @test_bob
    assert_equal @test_bob.login, 'bob'
    assert_equal  User.authenticate("nonbob", "test"), nil
    assert_equal    User.authenticate("nonbob", "bobs_secure_password"), nil
    assert_not_equal    User.authenticate("bob", "bobs_secure_password"), nil

  end

  def test_disallowed_passwords
		num_users = User.count

    u = User.new
    u.login = "nonbob"

    u.password = u.password_confirmation = "tiny"
    assert_equal false, u.save
    assert_equal ["is too short (minimum is 5 characters)", "password length must be between 5 and 40 characters"], u.errors['password']

    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert_equal false, u.save
    assert_equal ["is too long (maximum is 40 characters)", "password length must be between 5 and 40 characters"], u.errors['password']

    u.password = u.password_confirmation = ""
    assert_equal false, u.save
    assert_equal ["is too short (minimum is 5 characters)", "password length must be between 5 and 40 characters"], u.errors['password']

    assert_equal num_users, User.count

    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save
    assert u.errors.empty?

    assert_equal num_users + 1, User.count
  end

  def test_bad_logins

		num_users = User.count

    u = User.new
    u.password = u.password_confirmation = "bobs_secure_password"

    u.login = "x"
    assert !u.save
    assert_equal ["is too short (minimum is 3 characters)"], u.errors['login']

    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save
    assert_equal ["is too long (maximum is 40 characters)"], u.errors['login']

    u.login = ""
    assert !u.save
    assert_equal ["is too short (minimum is 3 characters)", "can't be blank"], u.errors['login']

    assert_equal num_users, User.count

    u.login = "okbob"
    assert u.save
    assert u.errors.empty?

    assert_equal num_users + 1, User.count

  end


  def test_collision

		num_users = User.count

    u = User.new
    u.login      = "existingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert !u.save

    assert_equal num_users, User.count

  end


  def test_create

		num_users = User.count

    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"

    assert u.save

    assert_equal num_users + 1, User.count

  end

  def test_sha1
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert u.save

    assert_equal '965e7c3bd4106311cca4d72163427c3ce9b2591f', u.password
  end

  def test_deactivate

		num_users = User.count

  	@user = User.find_by_login("bobareebop")
  	assert_equal @user.deactivated, 0	# activate
  	@user.deactivate
  	@user.save
  	@user.reload
  	assert_equal @user.deactivated, 1	# deactivated

    assert_equal num_users, User.count

  end

  def test_reactivate

		num_users = User.count

  	@user = User.find_by_login("bobout")
  	assert_equal @user.deactivated, 1	# deactivated
  	@user.reactivate
  	@user.save
  	@user.reload
  	assert_equal @user.deactivated, 0	# reactivated

    assert_equal num_users, User.count

  end

  def test_active_destroy

		num_users = User.count

  	@user = User.find_by_login("bobareebop")
  	assert_equal @user.deactivated, 0	# activate
  	@user.destroy
  	assert @user.errors.count > 0
  	assert_equal ['cannot destroy active record'], @user.errors[:deactivated]

    assert_equal num_users, User.count

  end

  def test_deactivated_destroy

		num_users = User.count

  	@user = User.find_by_login("bobout")
  	assert_equal @user.deactivated, 1	# deactivated
  	@user.destroy
  	assert @user.errors.count == 0

    assert_equal num_users - 1, User.count

  end

end
