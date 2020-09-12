module Statue
  class PostContentTransform < DOMTransform
    def transform
      at_each('table') do
        add_classes!(%w(table table-hover table-bordered))
      end
    end
  end
end
