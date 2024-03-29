module Statue
  class PageOutput
    attr_reader :page, :template

    def initialize(page, template:)
      @page = page
      @template = template
    end

    def description
      "Page"
    end

    def write_to(io)
      io.write(
        template.html(
          title: page.title,
          content: page.html_content,
          canonical_path: page.canonical_path,
        )
      )
    end

    def reset
      template.reset
    end

    def modified_since?(mtime)
      [page, template].any? { _1.modified_since?(mtime) }
    end
  end
end
