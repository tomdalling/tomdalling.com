module Statue
  class PostContentTransform < DOMTransform
    def initialize(modern_opengl_preamble_template:)
      super()
      @modern_opengl_preamble_template = modern_opengl_preamble_template
    end

    def transform
      at_each('table') do
        add_classes!(%w(table table-hover table-bordered))
      end

      at_each('widget') do
        outer_html!(render_widget(current_node))
      end
    end

    private

      def render_widget(node)
        if node[:type] == 'modern-opengl-preamble'
          @modern_opengl_preamble_template.dom(node)
        else
          fail("Unhandled widget type: #{node[:type]}")
        end
      end
  end
end
