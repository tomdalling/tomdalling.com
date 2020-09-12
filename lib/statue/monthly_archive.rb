module Statue
  class MonthlyArchive
    value_semantics do
      year Integer
      month Integer
      posts ArrayOf(Post)
    end

    def path
      Pathname('blog') / year.to_s / month.to_s.rjust(2, '0') / 'index.html'
    end

    def uri
      "/#{path.dirname}/"
    end

    def start_date
      Date.new(year, month, 1)
    end

    def human_month
      start_date.strftime('%B %Y')
    end

    def <=>(other)
      -(start_date <=> other.start_date)
    end

    def size
      posts.size
    end

    def post_index
      @post_index ||= PostIndex.new(
        title: "Archives: #{human_month}",
        posts: posts,
        path: path,
        feed_uri: '/blog/feed/',
        generate_feed?: false,
      )
    end
  end
end
