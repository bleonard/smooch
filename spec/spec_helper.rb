require 'rubygems'
require 'bundler'

Bundler.setup

RAILS_ENV = 'test'

# Load Rails
require 'active_support'
require 'action_controller'
require 'action_mailer'
require 'rails/version'

RAILS_ROOT = File.join(File.dirname(__FILE__))
$:.unshift(RAILS_ROOT)

ActionController::Base.view_paths = RAILS_ROOT
require File.join(RAILS_ROOT, 'application')

ActiveSupport::Dependencies.load_paths << File.join(File.dirname(__FILE__), '..', 'lib')

require 'spec/autorun'
require 'spec/rails'

require 'smooch'

Spec::Runner.configure do |config|
  
end
