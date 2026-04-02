module Statue
  class TagArchive
    value_semantics do
      tag Tag
      posts ArrayOf(Post)
    end

    def path
      Pathname(tag.uri.delete_prefix('/')) / 'index.html'
    end

    def uri
      "/#{path.dirname}/"
    end

    def feed_uri
      post_index.feed_uri
    end

    def size
      posts.size
    end

    def human_name
      tag.human_name
    end

    def <=>(other)
      tag.human_name <=> other.tag.human_name
    end

    def post_index
      @post_index ||= PostIndex.new(
        title: "Tag: #{human_name}",
        posts: posts,
        path: path,
      )
    end
  end
end
