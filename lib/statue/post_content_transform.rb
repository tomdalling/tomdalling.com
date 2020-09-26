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

      widget_scripts = []
      at_each('widget') do
        w = widget_for(current_node)
        outer_html!(w.render(current_node))
        widget_scripts.concat(w.scripts)
      end

      widget_scripts.uniq.each do
        append_html!(_1)
      end
    end

    private

      def widget_for(node)
        type = node[:type]
        widgets.find { _1.type == type } or fail("Unknown widget type: #{type}")
      end

      def widgets
        @widgets ||= [
          YoutubeWidget,
          TweetWidget,
          ModernOpenGLPreambleWidget.new(@modern_opengl_preamble_template),
        ]
      end

      class ModernOpenGLPreambleWidget
        def initialize(template)
          @template = template
        end

        def type
          'modern-opengl-preamble'
        end

        def render(node)
          @template.dom(node)
        end

        def scripts
          []
        end
      end

      module YoutubeWidget
        extend self

        def type
          'youtube'
        end

        def render(node)
          fragment = Nokogiri::HTML.fragment(<<~END_HTML)
            <figure class="youtube">
              <iframe
                src="https://www.youtube.com/embed/"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen
              ></iframe>
            </figure>
          END_HTML

          fragment.at_css('iframe').tap do
            vid = node[:video] or fail("Must supply video attr for youtube")
            _1[:src] = _1[:src] + vid
          end

          fragment
        end

        def scripts
          []
        end
      end

      module TweetWidget
        extend self

        def type
          'tweet'
        end

        def render(node)
          fragment = Nokogiri::HTML.fragment(<<~END_HTML)
            <figure class="naked">
              <blockquote class="twitter-tweet">
                <a href=""></a>
              </blockquote>
            </figure>
          END_HTML

          fragment.at_css('a').tap do
            _1[:href] = node[:href] or fail("Must supply href attr for tweet")
            _1.content = _1[:href]
          end

          fragment
        end

        def scripts
          ['<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>']
        end
      end
  end
end
