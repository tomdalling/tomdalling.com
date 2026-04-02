module Statue
  class Outputs
    include Memery

    def self.for(inputs)
      new(inputs).outputs
    end

    def outputs
      uniq_merge([
        canonical_outputs,
        duplicate_outputs,
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
          fail "Duplicate key #{key.inspect}"
        end
      end

      ##########################################################################
      # Outputs

      memoize def canonical_outputs
        uniq_merge([
          static_outputs,
          page_outputs,
          post_outputs,
          post_index_outputs,
          feed_outputs,
          css_outputs,
        ])
      end

      def duplicate_outputs
        uniq_merge([
          mvc_article_duplicate,
          tag_archive_duplicates,
          post_under_category_duplicates,
        ])
      end

      # This was the URL from the first time the article was published, a long
      # time ago, and it had a bunch of backlinks I wanted to preserve.
      def mvc_article_duplicate
        duplicate_output(
          canonical: "blog/model-view-controller-explained/index.html",
          duplicate: "software-design/model-view-controller-explained/index.html",
        )
      end

      def tag_archive_duplicates
        uniq_merge(
          tags.flat_map do |cat|
            [
              # old path: blog/category/X
              duplicate_output(
                canonical: "blog/tagged/#{cat.machine_name}/index.html",
                duplicate: "blog/category/#{cat.machine_name}/index.html",
              ),
              # old path: blog/X
              duplicate_output(
                canonical: "blog/tagged/#{cat.machine_name}/index.html",
                duplicate: "blog/#{cat.machine_name}/index.html",
              ),
              # same for feed
              duplicate_output(
                canonical: "blog/tagged/#{cat.machine_name}/feed/index.xml",
                duplicate: "blog/category/#{cat.machine_name}/feed/index.xml",
              ),
              # same for feed
              duplicate_output(
                canonical: "blog/tagged/#{cat.machine_name}/feed/index.xml",
                duplicate: "blog/#{cat.machine_name}/feed/index.xml",
              ),
            ]
          end
        )
      end

      # Previously all blog posts URLs included the post's category. This puts a
      # duplicate in the old location.
      def post_under_category_duplicates
        uniq_merge(
          posts.map do |p|
            duplicate_output(
              canonical: p.path,
              duplicate: p.old_categorised_path,
            )
          end
        )
      end

      def duplicate_output(canonical:, duplicate:)
        canonical_path = Pathname.new(canonical)
        duplicate_path = Pathname.new(duplicate)
        output = canonical_outputs.fetch(canonical_path) do
          fail "Can't duplicate non-existant output at #{canonical_path}"
        end
        { duplicate_path => output }
      end

      def static_outputs
        uniq_merge(
          inputs.descendants_of(STATIC_DIR).map do |i|
            path = i.path.relative_path_from(STATIC_DIR)
            output = StaticOutput.new(i)
            {path => output}
          end
        )
      end

      def post_outputs
        uniq_merge(
          posts.map do
            {_1.path => PostOutput.new(_1, template: post_template)}
          end
        )
      end

      def post_index_outputs
        uniq_merge(
          post_indexes.map do
            {_1.path => PostIndexOutput.new(_1, template: post_index_template)}
          end
        )
      end

      def feed_outputs
        uniq_merge(
          post_indexes.select(&:generate_feed?).map do |index|
            {
              index.feed_path =>
              FeedOutput.new(posts: index.posts, uri: index.feed_path.dirname.to_s + "/")
            }
          end
        ).tap do |outputs|
          # duplicate the "recent" feed to the old URL
          canonical_path = Pathname('blog/feed/index.xml')
          legacy_path = Pathname('feed/index.xml')
          outputs[legacy_path] = outputs.fetch(canonical_path)
        end
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

      # this is a bit of a hack to get the webpack output into the dev server
      def css_outputs
        {
          Pathname.new('style.css') => StaticOutput.new(inputs['frontend/dist/main.css'], allow_missing: true),
        }
      end

      ##########################################################################
      # Templates & Transforms

      memoize def page_template
        Template.new(
          html_file: inputs.get!(TEMPLATES_DIR / 'page.html'),
          is_document: true,
          transform: PageTransform.new(
            recent_posts: posts.take(5),
            yearly_archives: yearly_archives,
            tag_archives: tag_archives,
          ),
        )
      end

      memoize def post_index_template
        LayoutTemplate.new(
          page_template: page_template,
          content_template: Template.new(
            html_file: inputs.get!(TEMPLATES_DIR/"post-list.html"),
            transform: PostIndexTransform.new,
          )
        ) do |index|
          {
            title: index.title,
            canonical_path: index.canonical_uri,
          }
        end
      end

      memoize def post_template
        LayoutTemplate.new(
          page_template: page_template,
          content_template: Template.new(
            transform: PostTransform.new,
            html_file: inputs.get!(TEMPLATES_DIR/"post-single.html"),
          )
        ) do |post|
          {
            title: post.title,
            canonical_path: post.uri,
            social_metadata: post.social_metadata,
          }
        end
      end

      memoize def post_content_transform
        PostContentTransform.new(
          modern_opengl_preamble_template: Template.new(
            transform: ModernOpenGLPreambleTransform.new,
            html_file: inputs.get!(TEMPLATES_DIR/'modern-opengl-preamble-widget.html'),
          )
        )
      end

      ##########################################################################
      # Models

      memoize def posts
        inputs.descendants_of(POSTS_DIR)
          .map { Post.new(_1, content_transform: post_content_transform) }
          .sort
      end

      memoize def pages
        inputs.descendants_of(PAGES_DIR).map { Page.new(_1) }
      end

      memoize def monthly_archives
        posts
          .group_by { [_1.date.year, _1.date.month] }
          .map { MonthlyArchive.new(year: _1.first, month: _1.last, posts: _2) }
          .sort
      end

      memoize \
      def yearly_archives
        posts
          .group_by { _1.date.year }
          .map { YearlyArchive.new(year: _1, posts: _2) }
          .sort
      end

      memoize def tag_archives
        tags.map do |tag|
          TagArchive.new(
            tag: tag,
            posts: posts.select { _1.tagged?(tag) },
          )
        end.sort
      end

      memoize def tags
        posts.flat_map(&:tags).uniq
      end

      memoize def post_indexes
        [recent_post_index] +
          tag_archives.map(&:post_index) +
          monthly_archives.map(&:post_index) +
          yearly_archives.map(&:post_index)
      end

      def recent_post_index
        PostIndex.new(
          title: 'Recent Posts',
          posts: posts.take(10),
          path: 'blog/index.html',
        )
      end
  end
end
