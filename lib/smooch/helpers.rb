module Smooch
  module Helpers
    def km
      km = smooch_object
      km.view = self
      km
    end
  end
end