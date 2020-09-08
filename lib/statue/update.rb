module Statue
  class Update
    def self.actions_for(changeset)
      new(changeset).actions
    end

    def actions
      static_actions + post_actions + rss_actions + page_actions
    end

    private

      attr_reader :changeset

      def initialize(changeset)
        @changeset = changeset
      end

      def static_actions
        changeset.glob(static_dir/'**/*')
          .map { static_action_for(_1) }
          .compact
      end

      def static_dir
        changeset.dir / 'static'
      end

      def static_action_for(change)
        if change.added? || change.modified?
          Copy.new(
            source: change.path,
            destination: change.path.relative_path_from(static_dir),
          )
        elsif change.removed?
          Delete.new(
            destination: change.path.relative_path_from(static_dir),
          )
        else
          nil
        end
      end

      def post_actions
        changeset.glob(posts_dir/'*.{md,markdown}')
          .map { post_action_for(_1) }
          .compact
      end

      def post_action_for(change)
        if change.added? || change.modified?
          RenderPost.new(change.path)
        elsif change.removed?
          Delete.new(
            destination: Post.new(change.path).url_path / 'index.html'
          )
        else
          nil
        end
      end

      def rss_actions
        if changeset.glob(posts_dir/'**/*').any?
          [GenerateRSS.new(posts)]
        else
          []
        end
      end

      def posts_dir
        changeset.dir / 'posts'
      end

      def posts
        posts_dir.glob('*.{md,markdown}').map { Post.new(_1) }
      end

      def page_actions
        changeset.glob(pages_dir / '*.html')
          .map { page_action_for(_1) }
          .compact
      end

      def pages_dir
        changeset.dir / 'pages'
      end

      def page_action_for(change)
        if change.added? || change.modified?
          RenderPage.new(
            input_path: change.path,
            destination_path: change.path.relative_path_from(pages_dir),
          )
        elsif change.removed?
          Delete.new(destination: change.path.relative_path_from(pages_dir))
        else
          nil
        end
      end
  end
end
