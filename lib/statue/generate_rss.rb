module Statue
  class GenerateRSS
    attr_reader :posts

    def initialize(posts)
      @posts = posts
    end

    def description
      "Generate RSS #{destination}"
    end

    def call(output_dir)
      path = output_dir / destination
      FileUtils.mkdir_p(path.dirname)
      path.write(rss.to_xml)
    end

    def rss
      RSS.new(
        title: "Tom Dalling",
        site_url: BASE_URL + "/?utm_source=rss&utm_medium=rss",
        rss_url: BASE_URL + "/feed/",
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
        url: "#{BASE_URL}/#{post.url_basename}?utm_source=rss&utm_medium=rss",
        description: post.shortened_content,
        published_at: post.date.to_time,
        category: post.category,
        guid: RSS::GUID.new(value: post.disqus_id, permalink?: false),
      )
    end

    def destination
      Pathname.new('feed/index.xml')
    end
  end
end
