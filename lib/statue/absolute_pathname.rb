module Statue
  module AbsolutePathname
    def self.===(obj)
      Pathname === obj && obj.absolute?
    end
  end
end
