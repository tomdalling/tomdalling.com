module Statue
  class Page
    attr_reader :input_file

    def initialize(input_file)
      @input_file = input_file
    end

    def title
      frontmatter.title
    end

    def canonical_url
      frontmatter.canonical_url
    end

    def html_content
      loaded.last
    end

    def modified_since?(mtime)
      input_file.modified_since?(mtime)
    end

    private

      def loaded
        @loaded ||= EDN.split_frontmatter(input_file.read)
      end

      def frontmatter
        @frontmatter ||= Frontmatter.new(loaded.first)
      end

      class Frontmatter
        value_semantics do
          title String
          canonical_url Either(String, nil), default: nil
        end
      end
  end
end
