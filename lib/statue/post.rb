module Statue
  class Post
    attr_reader :input_path

    def initialize(input_path)
      @input_path = input_path
    end

    def title
      metadata.fetch(:title)
    end

    def category
      metadata.fetch(:category)
    end

    def disqus_id
      metadata.fetch(:'disqus-id')
    end

    def url_basename
      basename.partition('_').last
    end

    def url_path
      Pathname.new("blog").join(category.to_s, url_basename)
    end

    def basename
      input_path.basename.sub_ext('').to_s
    end

    def date
      Date.iso8601(basename.partition('_').first)
    end

    def metadata
      load_from_disk unless @metadata
      @metadata
    end

    def content
      load_from_disk unless @content
      @content
    end

    def html
      @html ||= Kramdown::Document.new(content).to_html
    end

    def human_category
      {
        'software-design': "Software Design",
        'coding-tips': "Coding Tips",
        'cocoa': "Cocoa",
        'coding-styleconventions': "Coding Style/Conventions",
        'software-processes': "Software Processes",
        'web': "Web",
        'modern-opengl': "Modern OpenGL Series",
        'ruby': "Ruby",
        'random-stuff': "Miscellaneous",
      }.fetch(category)
    end

    def preview_html
      more_separator = '<!--more-->'
      @preview_html ||=
        if html.include?(more_separator)
          html.partition(more_separator).first
        else
          html
        end
    end

    private

      def load_from_disk
        scanner = StringScanner.new(input_path.read)
        @metadata = EDN.read(scanner)
        @content = scanner.rest
        nil
      end
  end
end
