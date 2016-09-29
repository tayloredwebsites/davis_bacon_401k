require File.dirname(__FILE__) + '/../test_helper'

# Set salt to 'tayloredbenefits' because thats what the fixtures assume.
User.salt = 'tayloredbenefits'

class UserTest < Test::Unit::TestCase

  fixtures :users

  def test_auth

    @test_bob = User.authenticate("bob", "bobs_secure_password")
    assert_not_nil @test_bob
    assert_equal @test_bob.login, 'bob'
    # assert_equal  @bob, User.authenticate("bob", "bobs_secure_password")	# modified_at difference?
    assert  User.authenticate("nonbob", "test") == nil
    assert_nil    User.authenticate("nonbob", "bobs_secure_password")

  end

  def test_disallowed_passwords

		num_users = User.count

    u = User.new
    u.login = "nonbob"

    u.password = u.password_confirmation = "tiny"
    assert !u.save
    assert u.errors.invalid?('password')

    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save
    assert u.errors.invalid?('password')

    u.password = u.password_confirmation = ""
    assert !u.save
    assert u.errors.invalid?('password')

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
    assert u.errors.invalid?('login')

    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save
    assert u.errors.invalid?('login')

    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')

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
  	@user.update
  	@user.reload
  	assert_equal @user.deactivated, 1	# deactivated

    assert_equal num_users, User.count

  end

  def test_reactivate

		num_users = User.count

  	@user = User.find_by_login("bobout")
  	assert_equal @user.deactivated, 1	# deactivated
  	@user.reactivate
  	@user.update
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
  	assert_equal 'cannot destroy active record', @user.errors.on(:deactivated)

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
