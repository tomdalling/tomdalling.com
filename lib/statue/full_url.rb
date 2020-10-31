module Statue
  module FullURL
    def self.===(obj)
      Addressable::URI === obj && obj.host && obj.scheme
    end
  end
end
