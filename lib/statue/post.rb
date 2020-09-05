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

    def shortened_content
      more_separator = '<!--more-->'
      @shortened_content ||=
        if @content.include?(more_separator)
          @content.partition(more_separator).first
        else
          @content
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
