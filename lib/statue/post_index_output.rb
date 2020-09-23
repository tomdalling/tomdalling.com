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

    def write_to(output_path)
      output_path.write(html)
    end

    def html
      @html ||= template.html(post_index)
    end

    def modified_since?(mtime)
      [template, post_index].any? { _1.modified_since?(mtime) }
    end
  end
end
