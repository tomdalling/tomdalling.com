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

    def write_to(output_path)
      html = template.(post)
      output_path.write(html)
    end

    def modified_since?(mtime)
      [post, template].any? { _1.modified_since?(mtime) }
    end
  end
end
