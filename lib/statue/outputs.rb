module Statue
  class Outputs
    def self.for(inputs)
      new(inputs).outputs
    end

    def outputs
      uniq_merge([
        static_outputs,
        page_outputs,
        post_outputs,
        feed_outputs,
      ])
    end

    private

      POSTS_DIR = Pathname.new('posts')
      PAGES_DIR = Pathname.new('pages')
      STATIC_DIR = Pathname.new('static')
      TEMPLATES_DIR = Pathname.new('templates')

      attr_reader :inputs

      def initialize(inputs)
        @inputs = inputs
      end

      def uniq_merge(hashes)
        {}.merge!(*hashes) do |key, v1, v2|
          fail "Duplicate key #{key.inspect}: #{v1.inspect} AND #{v2.inspect}"
        end
      end

      ##########################################################################
      # Outputs

      def static_outputs
        uniq_merge(
          inputs.descendants_of(STATIC_DIR).map do
            path = _1.path.relative_path_from(STATIC_DIR)
            output = StaticOutput.new(_1)
            {path => output}
          end
        )
      end

      def post_outputs
        uniq_merge(
          posts.map do
            {_1.path => PostOutput.new(_1, template: post_page_template)}
          end
        )
      end

      def feed_outputs
        uniq_merge([full_feed_outputs, category_feed_outputs])
      end

      def full_feed_outputs
        feed = FeedOutput.new(posts: posts, uri: '/blog/feed/')
        {
          Pathname('feed/index.xml') => feed,
          Pathname('blog/feed/index.xml') => feed,
        }
      end

      def category_feed_outputs
        uniq_merge(
          category_archives.map do
            {
              _1.feed_path =>
              FeedOutput.new(posts: _1.posts, uri: _1.feed_uri)
            }
          end
        )
      end

      def page_outputs
        uniq_merge(
          pages.map do
            path = _1.input_file.path.relative_path_from(PAGES_DIR)
            output = PageOutput.new(_1, template: page_template)
            {path => output}
          end
        )
      end

      ##########################################################################
      # Templates

      def page_template
        @page_template ||= Template.new(
          html_file: inputs.get!(TEMPLATES_DIR/"page.html"),
          is_document: true,
          transform: PageTransform.new(
            recent_posts: recent_posts,
            monthly_archives: monthly_archives,
            category_archives: category_archives,
          ),
        )
      end

      def post_template
        @post_template ||= Template.new(
          transform: PostTransform.new,
          html_file: inputs.get!(TEMPLATES_DIR/"post.html"),
        )
      end

      def post_page_template
        @post_page_template ||= PostPageTemplate.new(
          post_template: post_template,
          page_template: page_template,
        )
      end

      ##########################################################################
      # Models

      def posts
        @posts ||= inputs.descendants_of(POSTS_DIR)
          .map { Post.new(_1) }
          .sort
      end

      def pages
        @pages ||= inputs.descendants_of(PAGES_DIR).map { Page.new(_1) }
      end

      def recent_posts
        posts.take(5)
      end

      def monthly_archives
        @monthly_archives ||=
          posts
            .group_by { [_1.date.year, _1.date.month] }
            .map { MonthlyArchive.new(year: _1.first, month: _1.last, posts: _2) }
            .sort
      end

      def category_archives
        @category_archives ||=
          posts
            .group_by(&:category)
            .map { CategoryArchive.new(category: _1, posts: _2) }
            .sort
      end
  end
end
