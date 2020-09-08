module Statue
  class Page
    attr_reader :html_content

    def initialize(html_content)
      @html_content = html_content
    end

    def title
      'TODO' # TODO: here
    end

    def canonical_url
      nil #TODO: here
    end
  end
end
