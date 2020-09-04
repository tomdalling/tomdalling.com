module Statue
  class Change
    TYPES = %i(added removed modified)

    value_semantics do
      path AbsolutePathname
      type Either(*TYPES)
    end

    TYPES.each do |type|
      class_eval <<~END_RUBY
        def self.#{type}(path)
          new(path: path, type: :#{type})
        end

        def #{type}?
          type == :#{type}
        end
      END_RUBY
    end
  end
end
