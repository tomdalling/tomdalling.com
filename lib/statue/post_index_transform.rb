module Statue
  class PostIndexTransform < DOMTransform
    def transform(post_index)
      at('h1 .title', post_index.title)
      at('h1 a.rss') do
        if post_index.generate_feed?
          attrs!(href: post_index.feed_uri)
        else
          remove!
        end
      end

      clone_each('article', post_index.posts) do |p|
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
