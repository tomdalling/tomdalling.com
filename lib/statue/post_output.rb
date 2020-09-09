module Statue
  class PostOutput
    attr_reader :post

    def initialize(post)
      @post = post
    end

    def description
      "Post"
    end

    def write_to(output_path)
      html = PostTemplate.new.call(post)
      output_path.write(html)
    end

    def modified_since?(mtime)
      post.modified_since?(mtime)
      # TODO: include template mtime
    end
  end
end
