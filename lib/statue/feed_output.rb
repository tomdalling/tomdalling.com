module Statue
  class FeedOutput
    attr_reader :posts, :uri

    def initialize(posts:, uri:)
      @posts = posts
      @uri = uri
    end

    def description
      "Feed"
    end

    def write_to(io)
      io.write(xml)
    end

    def modified_since?(mtime)
      # TODO: doesn't detect deleted files
      @posts.any? { _1.modified_since?(mtime) }
    end

    private
      def inspect
        "#<#{self.class} #{uri}>"
      end

      def xml
        @xml ||= rss.to_xml
      end

      def rss
        RSS.new(
          title: "Tom Dalling",
          site_url: BASE_URL.with_query("utm_source=rss&utm_medium=rss"),
          rss_url: BASE_URL.join(uri),
          description: "Web & software developer",
          language: "en",
          generator: "Tom Dalling's fingertips",
          update_period: 'daily',
          update_frequency: 1,
          items: posts.map { rss_item(_1) },
        )
      end

      def rss_item(post)
        RSS::Item.new(
          title: post.title,
          url: post.url.with_query('utm_source=rss&utm_medium=rss'),
          description: post.preview_html,
          published_at: Time.utc(post.date.year, post.date.month, post.date.day),
          category: post.category.human_name,
          guid: RSS::GUID.new(value: post.unique_id, permalink?: false),
        )
      end
    end
end
