module Statue
  class PageOutput
    attr_reader :page

    def initialize(page)
      @page = page
    end

    def description
      "Page"
    end

    def write_to(output_path)
      html = PageTemplate.new.call(page)
      output_path.write(html)
    end

    def modified_since?(mtime)
      page.modified_since?(mtime)
      # TODO: check if template is modified too
    end
  end
end
