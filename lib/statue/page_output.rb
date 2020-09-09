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

    def write_to(output_path)
      html = template.(page)
      output_path.write(html)
    end

    def modified_since?(mtime)
      [page, template].any? { _1.modified_since?(mtime) }
    end
  end
end
