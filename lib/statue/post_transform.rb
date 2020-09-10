module Statue
  class PostTransform < DOMTransform
    def transform(post)
      at('h1 a', post.title, href: post.uri)

      at(:header) do
        at('.main-image') { transform_main_image(post.main_image) }
        at('a.category', post.category.human_name, href: post.category.uri)
      end

      at('.post-date', post.date.strftime("%-d %b, %Y"))

      at('.post-content') { html!(post.html) }

      at('#disqus_script') do
        if post.draft?
          remove!
        else
          interpolate_text!({
            'disqus-id' => JSON.dump(post.disqus_id),
            'disqus-title' => JSON.dump(post.title),
            'disqus-url' => JSON.dump(post.url),
          })
        end
      end
    end

    private

      def transform_main_image(main_image)
        if main_image.nil?
          remove!
          return
        end

        at(:img, src: main_image.uri)

        at('.credit') do
          if main_image.artist
            at('a.artist', main_image.artist.name, href: main_image.artist.url)
          else
            remove!
          end
        end
      end
  end
end
