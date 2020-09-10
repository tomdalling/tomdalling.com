module Statue
  class PageTransform < DOMTransform
    attr_reader :recent_posts, :monthly_archives, :category_archives

    def initialize(recent_posts:, monthly_archives:, category_archives:)
      super()
      @recent_posts = recent_posts
      @monthly_archives = monthly_archives
      @category_archives = category_archives
    end

    private

      def transform(title:, content:, canonical_url: nil)
        if canonical_url
          at(:head) { append!(:link, rel: "canonical", href: canonical_url) }
        end

        at(:title) { prepend_text!(title) }

        clone_each('ul.recent-posts li', recent_posts) do |post|
          at(:a, post.title, href: post.uri)
        end

        clone_each('ul.archives li', monthly_archives) do |archive|
          at(:a, href: archive.uri)
          at('.month', archive.human_month)
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
  end
end
