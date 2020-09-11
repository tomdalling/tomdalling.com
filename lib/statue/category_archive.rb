module Statue
  class CategoryArchive
    value_semantics do
      category Category
      posts ArrayOf(Post)
    end

    def path
      Pathname("blog/category") / category.machine_name / 'index.html'
    end

    def uri
      "/#{path.dirname}/"
    end

    def feed_uri
      legacy_post_index.feed_uri
    end

    def size
      posts.size
    end

    def human_name
      category.human_name
    end

    def <=>(other)
      category.human_name <=> other.category.human_name
    end

    # TODO: this legacy index isn't so legacy. I should move it over.
    # legacy url is used as the canonical, and the rss feed is under the legacy
    # path too.
    def legacy_post_index
      @legacy_post_index ||= PostIndex.new(
        title: "Category: #{human_name}",
        posts: posts,
        path: path,
      )
    end

    def post_index
      @post_index ||= legacy_post_index.with(
        path: Pathname('blog') / category.machine_name / 'index.html',
        feed?: false,
      )
    end
  end
end
