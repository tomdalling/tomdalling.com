module Statue
  module PathnameCoercer
    def self.call(obj)
      if obj.is_a?(String)
        Pathname.new(obj)
      else
        obj
      end
    end
  end
end
