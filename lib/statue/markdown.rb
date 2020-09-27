require 'rouge/plugins/redcarpet'

module Statue
  module Markdown
    extend self

    def to_html(markdown)
      opts = {
        input: 'GFM',
        hard_wrap: false,
        auto_ids: false,
        gfm_quirks: %w(paragraph_end),
      }
      Kramdown::Document.new(markdown, opts).to_html
    end

    private
  end
end
