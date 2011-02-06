require 'smooch/base'
require 'smooch/helpers'
require 'smooch/controller'

ActionController::Base.class_eval do
  extend Smooch::Controller
end
