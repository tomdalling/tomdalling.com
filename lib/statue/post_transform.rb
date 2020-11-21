module Statue
  class PostTransform < DOMTransform
    def transform(post)
      at('h1 a', post.title, href: post.uri)

      at(:header) do
        at('.main-image') { transform_main_image(post.main_image) }
        at('a.category', post.category.human_name, href: post.category.uri)
        at('.bleet') { remove! unless post.bleet? }
      end

      at('.post-date', post.human_date)
      at_each('a.post-github', href: post.github_url)
      at('.post-content') { html!(post.html) }

      at('#post-comments') do
        if post.draft? || post.disqus_id.nil?
          remove!
        else
          at('#disqus_script') do
            interpolate_text!({
              'disqus-id' => JSON.dump(post.disqus_id),
              'disqus-title' => JSON.dump(post.title),
              'disqus-url' => JSON.dump(post.url),
            })
          end
          unwrap!
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
