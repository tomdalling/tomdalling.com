module Statue
  class PageTransformer < DOMTransformer
    def setup(posts:)
      @posts = posts
    end

    def transform(title:, content:, canonical_url: nil)
      if canonical_url
        at(:head) { append!(:link, rel: "canonical", href: canonical_url) }
      end

      at(:title) { prepend_text!(title) }

      clone_each('ul.recent-posts li', recent_posts) do |post|
        at(:a, post.title, href: "/#{post.canonical_path}")
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

    private

      attr_reader :posts

      def monthly_archives
        MonthlyArchive.all_for(posts)
      end

      def category_archives
        CategoryArchive.all_for(posts)
      end

      def recent_posts
        posts.sort_by(&:date).reverse.take(5)
      end
  end
end
