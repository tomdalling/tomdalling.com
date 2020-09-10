module Statue
  class CategoryArchive
    value_semantics do
      category Category
      posts ArrayOf(Post)
    end

    def path
      Pathname("blog/category") / category.machine_name / 'index.html'
    end

    def feed_path
      path.dirname / 'feed/index.xml'
    end

    def uri
      "/#{path.dirname}/"
    end

    def feed_uri
      "/#{feed_path.dirname}/"
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
