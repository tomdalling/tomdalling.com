module Statue
  class PostIndexOutput
    attr_reader :template, :title, :posts, :feed_uri

    def initialize(template:, title:, posts:, feed_uri: nil)
      @template = template
      @title = title
      @posts = posts
      @feed_uri = feed_uri
    end

    def description
      'Post Index'
    end

    def write_to(output_path)
      output_path.write(
        template.html(
          title: title,
          posts: posts,
          feed_uri: feed_uri,
        )
      )
    end
  end
end
