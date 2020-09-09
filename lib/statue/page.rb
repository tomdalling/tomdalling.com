module Statue
  class Page
    attr_reader :input_file

    def initialize(input_file)
      @input_file = input_file
    end

    def url_path
      input_file.path
    end

    def title
      'TODO' # TODO: here
    end

    def html_content
      @html_content ||= input_file.read
    end

    def modified_since?(mtime)
      input_file.modified_since?(mtime)
    end
  end
end
