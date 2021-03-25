module Statue
  class YearlyArchive
    value_semantics do
      year Integer
      posts ArrayOf(Post)
    end

    def <=>(other)
      -(year <=> other.year)
    end

    def path
      Pathname('blog') / year.to_s / 'index.html'
    end

    def uri
      "/#{path.dirname}/"
    end

    def size
      posts.size
    end

    def post_index
      @post_index ||= PostIndex.new(
        title: "#{year} Archives",
        posts: posts,
        path: path,
        generate_feed?: false,
      )
    end
  end
end
