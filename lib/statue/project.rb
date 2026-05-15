module Statue
  class Project
    attr_reader :markdown_file

    def initialize(markdown_file)
      @markdown_file = markdown_file
    end

    extend Forwardable
    def_delegator :markdown_file, :modified_since?
    def_delegators :frontmatter, :title, :url, :description, :image, :background_color, :accent_color, :color

    def <=>(other)
      title <=> other.title
    end

    def slug
      markdown_file.path.basename.sub_ext('').to_s
    end

    private

      def loaded
        @loaded ||= EDN.split_frontmatter(markdown_file.read)
      rescue => ex
        raise "Failed to load #{markdown_file.path}: #{ex}"
      end

      def frontmatter
        @frontmatter ||= Frontmatter.new(loaded.first)
      end

      class Frontmatter
        value_semantics do
          title String
          url String
          description String
          background_color String
          accent_color String
          color String
        end
      end
  end
end
