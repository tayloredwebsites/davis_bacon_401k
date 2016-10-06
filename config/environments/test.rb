# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils    = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection = false

# print logging statements out during tests
#log4r
require "log4r"
config.log_level = :debug
Log4r::Logger.root.level = Log4r::DEBUG
formatter = Log4r::PatternFormatter.new(:pattern => "[%5l] %d %30C - %m")
Log4r::StderrOutputter.new('console', :formatter => formatter)
Log4r::Logger.new('App').add('console')
RAILS_DEFAULT_LOGGER = Log4r::Logger.new('App::Rails')
