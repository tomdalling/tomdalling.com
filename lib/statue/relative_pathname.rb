module Statue
  module RelativePathname
    def self.===(obj)
      Pathname === obj && obj.relative?
    end
  end
end
