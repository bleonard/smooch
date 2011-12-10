module Smooch
  API_KEY = ''
  
  def self.ab_static?
    !!@ab_static
  end
  def self.ab_static=val
    @ab_static=val
  end
  
end

begin
  config = YAML.load_file("#{RAILS_ROOT}/config/kissmetrics.yml")
  Smooch::API_KEY = config[RAILS_ENV]['apikey'] if config[RAILS_ENV]
rescue
  puts "Error opening KISSmetrics configuration file."
end

require 'smooch/base'
require 'smooch/helpers'
require 'smooch/controller'



ActionController::Base.class_eval do
  extend Smooch::Controller
end
