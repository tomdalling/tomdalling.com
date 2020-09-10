module Statue
  class CategoryArchive
    value_semantics do
      category Category
      posts ArrayOf(Post)
    end

    def self.all_for(posts)
      posts
        .group_by(&:category)
        .map { new(category: _1, posts: _2) }
        .sort
    end

    def uri
      "/blog/category/#{category.machine_name}/"
    end

    def feed_uri
      "#{uri}feed/"
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
  end
end
