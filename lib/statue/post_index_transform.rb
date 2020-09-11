module Statue
  class PostIndexTransform < DOMTransform
    def transform(title:, posts:, feed_uri: nil)
      at('h1 .title', title)

      at('h1 a.rss') do
        if feed_uri
          attrs!(href: feed_uri)
        else
          remove!
        end
      end

      clone_each('article', posts) do |p|
        at('h2 a', p.title, href: p.uri)
        at('header a.category', p.category.human_name, href: p.category.uri)
        at('.listed-main-image', src: p.main_image&.uri)
        at('.post-date', p.human_date)
        at('.post-content') { html!(p.preview_html) }
        at('a.more', href: p.uri)
      end
    end
  end
end
