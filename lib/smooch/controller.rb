require "digest/md5"

module Smooch
  COOKIE_ID = "ab_id"
  
  module Controller
    def kiss(symbol = nil, &block)
      if block
        define_method(:smooch_calculate_identity) { block.call(self) }
      else
        define_method :smooch_calculate_identity do
          return @smooch_identity if @smooch_identity
          if symbol && object = send(symbol)
            @smooch_identity = object.id
          elsif response # everyday use
            @smooch_generated = true
            @smooch_identity = cookies[COOKIE_ID] || ActiveSupport::SecureRandom.hex(16)
            cookies[COOKIE_ID] = { :value=>@smooch_identity, :expires=>1.month.from_now }
            @smooch_identity
          else
            @smooch_identity = "test"
          end
        end
      end
      
      define_method(:smooch_identity) do
        smooch_calculate_identity
      end
      define_method(:kiss_identity) do
        val = smooch_calculate_identity
        return "null" if @smooch_generated
        val
      end
      
      define_method(:smooch_object) do
        @smooch_object ||= Smooch::Base.new(self)
      end
      define_method(:km) do
        smooch_object
      end
      helper_method :smooch_object
      helper Smooch::Helpers
    end
    protected :kiss
  end
end