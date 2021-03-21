module Statue
  class PostOutput
    attr_reader :post, :template

    def initialize(post, template:)
      @post = post
      @template = template
    end

    def description
      "Post"
    end

    def write_to(io)
      io.write(
        template.html(post)
      )
    end

    def reset
      @post.reset
      @template.reset
    end

    def modified_since?(mtime)
      [post, template].any? { _1.modified_since?(mtime) }
    end
  end
end
