module Statue
  class TreeBuilder
    def self.build
      new.build
    end

    def build
      Tree.new
    end
  end
end
