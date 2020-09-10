module Statue
  class Template
    attr_reader :transform, :html_file, :setup

    def initialize(transform:, html_file:, is_document: false, setup: {})
      @transform = transform
      @html_file = html_file
      @setup = setup
      @is_document = is_document
    end

    def fragment?
      not document?
    end

    def document?
      @is_document
    end

    def dom(*args, **kwargs, &block)
      original_dom.clone.tap do
        transform.(_1, *args, **kwargs, &block)
      end
    end

    def html(...)
      dom(...).to_html.tap do |html|
        if document?
          # wtf libxml2. get outa hea
          html.gsub!(/\<meta http-equiv=.Content-Type. [^>]+\>/, '')
        end
      end
    end

    private

      def original_dom
        @original_dom ||= begin
          parser = Nokogiri::HTML.method(fragment? ? :fragment : :parse)
          parser.(html_file.read)
        end
      end
  end
end
