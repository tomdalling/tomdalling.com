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
        case node[:type]
        when 'modern-opengl-preamble'
          @modern_opengl_preamble_template.dom(node)
        when 'youtube'
          vid = node[:video] || fail("Must supply video attr on <youtube />")
          Nokogiri::HTML.fragment(<<~END_HTML)
            <figure class="youtube">
              <iframe
                src="https://www.youtube.com/embed/#{vid}"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen
              ></iframe>
            </figure>
          END_HTML
        else
          fail("Unhandled widget type: #{node[:type]}")
        end
      end
  end
end
