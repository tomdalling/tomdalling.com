module Statue
  class PostIndex
    value_semantics do
      path RelativePathname, coerce: Pathname.method(:new)
      posts ArrayOf(Post)
      title String
      has_feed? Bool(), default: true
    end

    def uri
      "/#{path.dirname}/"
    end

    def feed_path
      path.dirname / 'feed/index.xml'
    end

    def feed_uri
      "/#{feed_path.dirname}/"
    end
  end
end
