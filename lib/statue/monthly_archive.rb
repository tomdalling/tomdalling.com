module Statue
  class MonthlyArchive
    value_semantics do
      year Integer
      month Integer
      posts ArrayOf(Post)
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
      -(start_date <=> other.start_date)
    end

    def size
      posts.size
    end
  end
end
