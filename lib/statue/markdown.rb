require 'rouge/plugins/redcarpet'

module Statue
  module Markdown
    extend self

    def to_html(markdown)
      redcarpet.render(markdown)
    end

    private

      def redcarpet
        @redcarpet ||= Redcarpet::Markdown.new(
          Renderer,
          fenced_code_blocks: true,
          autolink: true,
          strikethrough: true,
          tables: true,
        )
      end

      class Renderer < Redcarpet::Render::HTML
        include Rouge::Plugins::Redcarpet
        include Redcarpet::Render::SmartyPants
      end
  end
end
