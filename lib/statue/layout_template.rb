module Statue
  class LayoutTemplate
    attr_reader :content_template, :page_template, :page_args_block

    def initialize(content_template:, page_template:, &page_args_block)
      @content_template = content_template
      @page_template = page_template
      @page_args_block = page_args_block
    end

    def reset
      @page_template.reset
      @content_template.reset
    end

    def html(...)
      page_template.html(
        content: content_template.dom(...),
        **page_args_block.(...),
      )
    end

    def modified_since?(mtime)
      [content_template, page_template].any? { _1.modified_since?(mtime) }
    end
  end
end
