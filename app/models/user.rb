require 'digest/sha1'

class User < ActiveRecord::Base

  attr_accessible :login, :password, :password_confirmation, :deactivated, :supervisor

  before_create :crypt_unless_empty, :create_timestamp
  before_update :crypt_unless_empty


  validates_uniqueness_of :login, :on => :create

  validates_confirmation_of :password, :on => :create
  #?validates_confirmation_of :password
  validates_length_of :login, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :login

  validate :validate_create, on: :create
  validate :validate_update, on: :update
  validate :validate_destroy, on: :destroy



  # Authenticate a user.
  #
  # Example:
  #   @user = User.authenticate('bob', 'bobpass')
  #
  def self.authenticate(login, pass)
    matches = User.where(login: login, password: sha1(pass))
    Rails.logger.debug("*** matches.count: #{matches.count}")
    Rails.logger.debug("*** matches: #{matches.all.inspect}")
    return matches.count > 0 ? matches.first : nil
  end


  protected

  # Please change the salt to something else,
  # Every application should use a different one
  @@salt = 'tayloredbenefits'
  # is this still needed?
  cattr_accessor :salt

  # Apply SHA1 encryption to the supplied password.
  # We will additionally surround the password with a salt
  # for additional security.
  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end


  # Before saving the record to database we will crypt the password
  # using SHA1.
  # We never store the actual password in the DB.
  # this method has been replaced by :crypt_unless_empty
  #def crypt_password
  #  write_attribute "password", self.class.sha1(password)
  #end

  # If the record is updated we will check if the password is empty.
  # If its empty we assume that the user didn't want to change his
  # password and just reset it to the old value.
  def crypt_unless_empty
    Rails.logger.debug("*** crypt_unless_empty password: #{password.inspect}")
    if password.empty?
      user = User.find(self.id)
      Rails.logger.debug("*** crypt_unless_empty user: #{user.inspect}")
      self.password = user.password
    else
      write_attribute "password", self.class.sha1(password)
    end
    Rails.logger.debug("*** crypt_unless_empty password: #{password.inspect}")
  end

  # Properly set the current date and time in the created_at field on creation
  def create_timestamp
    self.created_at = Time.now
  end

  # make sure password length is good for all creates
  def validate_create
    if read_attribute(:password).blank? || read_attribute(:password).length < 5 || read_attribute(:password).length > 40
      errors.add(:password, "password length must be between 5 and 40 characters")
    end
  end

  # make sure password length is good for updates only when password is changed
  def validate_update
    if read_attribute(:password).present?
      if  read_attribute(:password).length < 5 || read_attribute(:password).length > 40
        errors.add(:password, "password length must be between 5 and 40 characters")
      end
    end
  end

  #before_destroy :validate_on_destroy

  # make sure record is deactivated before destroying
  def validate_destroy
    if self.deactivated == 0
      errors.add(:deactivated, "cannot destroy active record")
      #raise "Error - cannot destroy active record"
    end
  end

public  ## following methods will be public

  # wrote this, because validate_on_destroy errors did not pass to destroy method
  def destroy
    if self.deactivated == 0
      errors.add(:deactivated, "cannot destroy active record")
      #raise "Error - cannot destroy active record"
    end
    if errors.empty?
      super
    #else
    # errors.add(:deactivated, "destroy active record - errors")
    end
  end

  # method to deactivate record
  def deactivate
    if self.deactivated == 0
      self.deactivated = 1;
    else
      errors.add(:deactivated, "record already deactivated")
    end
  end

  def reactivate
    if self.deactivated == 1
      self.deactivated = 0;
    else
      errors.add(:deactivated, "record already reactivated")
    end
  end

end
