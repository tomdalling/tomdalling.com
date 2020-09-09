module Statue
  class Outputs
    def self.for(inputs)
      new(inputs).outputs
    end

    def outputs
      uniq_merge([
        static_outputs,
        post_outputs,
        feed_outputs,
        page_outputs,
      ])
    end

    private

      attr_reader :inputs

      def initialize(inputs)
        @inputs = inputs
      end

      def posts_dir
        Pathname.new('posts')
      end

      def pages_dir
        Pathname.new('pages')
      end

      def static_dir
        Pathname.new('static')
      end

      def templates_dir
        Pathname.new('templates')
      end

      def static_outputs
        inputs.descendants_of(static_dir)
          .map { static_output_for(_1) }
          .then { uniq_merge(_1) }
      end

      def static_output_for(input_file)
        {
          input_file.path.relative_path_from(static_dir) =>
          StaticOutput.new(input_file)
        }
      end

      def post_outputs
        posts
          .map { post_output_for(_1) }
          .then { uniq_merge(_1) }
      end

      def posts
        @posts ||= inputs.descendants_of(posts_dir).map { Post.new(_1) }
      end

      def post_output_for(post)
        {
          post.canonical_path.join('index.html') =>
          PostOutput.new(post, template: PostTemplate.new(template_file('post')))
        }
      end

      def feed_outputs
        # TODO: i think there is a feed per category too
        feed = FeedOutput.new(posts)
        {
          Pathname('feed/index.xml') => feed,
          Pathname('blog/feed/index.xml') => feed,
        }
      end

      def page_outputs
        pages
          .map { page_output_for(_1) }
          .then { uniq_merge(_1) }
      end

      def page_output_for(page)
        {
          page.url_path.relative_path_from(pages_dir) =>
          PageOutput.new(page, template: PageTemplate.new(template_file('page')))
        }
      end

      def pages
        @pages ||= inputs.descendants_of(pages_dir).map { Page.new(_1) }
      end

      def uniq_merge(hashes)
        {}.merge!(*hashes) do |key, v1, v2|
          fail "Duplicate key #{key.inspect}: #{v1.inspect} AND #{v2.inspect}"
        end
      end

      def template_file(name)
        inputs["templates/#{name}.html"] or fail("Template not found: #{name}")
      end
  end
end
