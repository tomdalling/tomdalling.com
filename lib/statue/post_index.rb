module Statue
  class PostIndex
    value_semantics do
      path RelativePathname, coerce: Pathname.method(:new)
      canonical_path Either(RelativePathname, nil), default: nil
      posts ArrayOf(Post)
      title String
      feed_uri Either(String, nil), default: nil
      generate_feed? Bool(), default: true
    end

    def canonical_path
      super || path
    end

    def canonical_uri
      "/#{canonical_path.dirname}/"
    end

    def feed_path
      canonical_path.dirname / 'feed/index.xml'
    end

    def feed_uri
      super || "/#{feed_path.dirname}/"
    end

    def modified_since?(mtime)
      posts.any? { _1.modified_since?(mtime) }
    end
  end
end
