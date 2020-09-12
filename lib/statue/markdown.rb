require 'rouge/plugins/redcarpet'

module Statue
  module Markdown
    extend self

    def to_html(markdown)
      opts = {
        input: 'GFM',
        hard_wrap: false,
        auto_ids: false,
        smart_quotes: ["apos", "apos", "quot", "quot"], # TODO: turn this on
        typographic_symbols: {}, # TODO: turn this on
        gfm_quirks: %w(paragraph_end no_auto_typographic),
      }
      Kramdown::Document.new(markdown, opts).to_html
    end

    private
  end
end
