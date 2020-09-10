module Statue
  class PostPageTemplate
    attr_reader :post_template, :page_template

    def initialize(post_template:, page_template:)
      @post_template = post_template
      @page_template = page_template
    end

    def html(post)
      page_template.html(
        title: post.title,
        content: post_template.dom(post),
        canonical_url: post.url,
      )
    end

    def modified_since?(mtime)
      [post_template, page_template].any? { _1.modified_since?(mtime) }
    end
  end
end
