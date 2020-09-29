module Statue
  class PostIndex
    value_semantics do
      path RelativePathname, coerce: Pathname.method(:new)
      posts ArrayOf(Post)
      title String
      generate_feed? Bool(), default: true
    end

    def reset
      posts.each(&:reset)
    end

    def canonical_uri
      "/#{path.dirname}/"
    end

    def feed_path
      path.dirname / 'feed/index.xml'
    end

    def feed_uri
      "/#{feed_path.dirname}/"
    end

    def modified_since?(mtime)
      posts.any? { _1.modified_since?(mtime) }
    end
  end
end
