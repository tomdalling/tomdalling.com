module Statue
  class PageTransform < DOMTransform
    attr_reader :recent_posts, :yearly_archives, :category_archives

    def initialize(recent_posts:, yearly_archives:, category_archives:)
      super()
      @recent_posts = recent_posts
      @yearly_archives = yearly_archives
      @category_archives = category_archives
    end

    private

      def transform(title:, content:, canonical_path: nil, social_metadata: nil)
        canonical_url = canonical_path ? BASE_URL / canonical_path : nil
        if canonical_url
          at(:head) { append!(:link, rel: "canonical", href: canonical_url) }
        end

        add_social_metas(social_metadata, canonical_url)

        at(:title) { prepend_text!(title) }

        clone_each('ul.recent-posts li', recent_posts) do |post|
          at(:a, post.title, href: post.uri)
        end

        clone_each('ul.archives li', yearly_archives) do |archive|
          at(:a, href: archive.uri)
          at('.year', archive.year.to_s)
          at('.post-count', archive.size)
        end

        clone_each('ul.categories li', category_archives) do |archive|
          at('a.category', archive.human_name, href: archive.uri)
          at('a.feed', href: archive.feed_uri)
          at('.post-count', archive.size)
        end

        at('.current-year') { text!(Date.today.year) }

        at(:main) { html!(content) }
      end

      def add_social_metas(social_metadata, canonical_url)
        return unless social_metadata

        at(:head) do
          append!(:meta, property: 'og:title', content: social_metadata.title)

          if canonical_url
            append!(:meta, property: 'og:url', content: canonical_url)
          end

          if social_metadata.image_url
            append!(:meta, property: 'og:image', content: social_metadata.image_url.to_s)
            append!(:meta, name: 'twitter:card', content: 'summary_large_image')
          else
            append!(:meta, name: 'twitter:card', content: 'summary')
          end
        end
      end
  end
end
