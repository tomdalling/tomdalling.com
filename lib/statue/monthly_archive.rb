module Statue
  class MonthlyArchive
    value_semantics do
      year Integer
      month Integer
      posts ArrayOf(Post)
    end

    def self.all_for(posts)
      posts
        .group_by { [_1.date.year, _1.date.month] }
        .map { |ym, posts| new(year: ym.first, month: ym.last, posts: posts) }
        .sort
        .reverse
    end

    def uri
      "/blog/#{year}/#{month.to_s.rjust(2, '0')}/"
    end

    def start_date
      Date.new(year, month, 1)
    end

    def human_month
      start_date.strftime('%B %Y')
    end

    def <=>(other)
      start_date <=> other.start_date
    end

    def size
      posts.size
    end
  end
end
