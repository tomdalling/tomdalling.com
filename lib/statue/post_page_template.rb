module Statue
  class PostPageTemplate
    attr_reader :post_template, :page_template

    def initialize(post_template:, page_template:)
      @post_template = post_template
      @page_template = page_template
    end

    def call(post)
      page_template.(
        title: post.title,
        html_content: post_template.(post),
        canonical_url: post.canonical_url,
      )
    end

    def modified_since?(mtime)
      [post_template, page_template].any? { _1.modified_since?(mtime) }
    end
  end
end
