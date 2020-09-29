module Statue
  class PostIndexOutput
    attr_reader :post_index, :template

    def initialize(post_index, template:)
      @post_index = post_index
      @template = template
    end

    def description
      'Post Index'
    end

    def write_to(io)
      io.write(html)
    end

    def reset
      @html = nil
      @post_index.reset
    end

    def html
      @html ||= template.html(post_index)
    end

    def modified_since?(mtime)
      [template, post_index].any? { _1.modified_since?(mtime) }
    end
  end
end
