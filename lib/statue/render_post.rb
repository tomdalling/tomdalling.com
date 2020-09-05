module Statue
  class RenderPost
    def initialize(source_path)
      @source_path = source_path
    end

    def description
      "Render post #{post.url_path}"
    end

    def call(output_dir)
      path = output_dir / post.url_path / 'index.html'
      FileUtils.mkdir_p(path.dirname)
      path.write(post.html)
    end

    private

      def post
        @post ||= Post.new(@source_path)
      end
  end
end
