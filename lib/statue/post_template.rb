module Statue
  class PostTemplate
    attr_reader :doc, :template_file

    def initialize(template_file)
      @template_file = template_file
      @doc = nil
    end

    def call(post)
      reset!

      xform('h1 a') do
        _1.content = post.title
        _1[:href] = "/#{post.canonical_path}/"
      end

      xform('header .main-image') do
        _1.remove unless post.main_image
      end

      xform('header .main-image .credit') do
        _1.remove unless post.main_image.artist
      end

      xform('header .main-image img') do
        _1[:src] = post.main_image.uri
      end

      xform('header .main-image a.artist') do
        _1.content = post.main_image.artist.name
        _1[:href] = post.main_image.artist.url
      end

      xform('header a.category') do
        _1.content = post.category.human_name
        _1[:href] = post.category.uri
      end

      xform('.post-date') do
        _1.content = post.date.strftime("%-d %b, %Y")
      end

      xform('.post-content') do
        _1.inner_html = post.html
      end

      xform('#disqus_script') do
        if post.draft?
          _1.remove
        else
          _1.content = interpolate_js(_1.content, {
            'disqus-id' => post.disqus_id,
            'disqus-title' => post.title,
            'disqus-url' => post.canonical_url,
          })
        end
      end

      doc.to_html
    end

    private

      # TODO: gross
      def reset!
        @original_doc ||= Nokogiri::HTML(template_file.read)
        @doc = @original_doc.clone
      end

      def xform(css_specifier)
        doc.css(css_specifier).each do
          yield _1
        end
      end

      def interpolate_js(js, substitutions)
        js.dup.tap do |result|
          substitutions.each do |(var, value)|
            result["${#{var}}"] = JSON.dump(value)
          end
        end
      end
  end
end
