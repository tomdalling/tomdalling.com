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

    def write_to(output_path)
      output_path.write(xml)
    end

    def modified_since?(mtime)
      # TODO: doesn't detect deleted files
      @posts.any? { _1.modified_since?(mtime) }
    end

    private

      def xml
        @xml ||= rss.to_xml
      end

      def rss
        RSS.new(
          title: "Tom Dalling",
          site_url: BASE_URL + "/?utm_source=rss&utm_medium=rss",
          rss_url: BASE_URL + uri,
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
          url: "#{post.url}?utm_source=rss&utm_medium=rss",
          description: post.preview_html,
          published_at: Time.utc(post.date.year, post.date.month, post.date.day),
          category: post.category.human_name,
          guid: RSS::GUID.new(value: post.disqus_id, permalink?: false),
        )
      end
    end
end
