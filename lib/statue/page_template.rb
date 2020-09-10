module Statue
  class PageTemplate
    attr_reader :doc, :template_file, :posts

    def initialize(template_file, posts:)
      @template_file = template_file
      @posts = posts
      @doc = nil
    end

    # TODO: posts are not optional
    def call(title:, html_content:, canonical_url: nil)
      reset!

      if canonical_url
        doc.at_css('head').add_child('<link />').first.tap do
          _1[:rel] = "canonical"
          _1[:href] = canonical_url
        end
      end

      xform('title') do
        _1.content = title + _1.content
      end

      xform('main') do
        _1.inner_html = html_content
      end

      clone_each('ul.recent-posts li', recent_posts) do |node, post|
        xform('a', within: node) do
          _1.content = post.title
          _1[:href] = "/#{post.canonical_path}"
        end
      end

      # TODO: MonthlyArchive array should be cached once per build
      clone_each('ul.archives li', MonthlyArchive.all_for(posts)) do |node, archive|
        xform('a', within: node) { _1[:href] = archive.uri }
        xform('.month', within: node) { _1.content = archive.human_month }
        xform('.post-count', within: node) { _1.content = archive.size }
      end

      clone_each('ul.categories li', CategoryArchive.all_for(posts)) do |node, archive|
        xform('a.category', within: node) do
          _1[:href] = archive.uri
          _1.content = archive.human_name
        end
        xform('a.feed', within: node) { _1[:href] = archive.feed_uri }
        xform('.post-count', within: node) { _1.content = archive.size }
      end

      xform('.current-year') do
        _1.content = Date.today.year
      end

      html = doc.to_html
      # wtf libxml2. get outa hea
      html.gsub!(/\<meta http-equiv=.Content-Type. [^>]+\>/, '')
      html
    end

    private

      #TODO: gross
      def reset!
        @original_doc ||= Nokogiri::HTML.parse(template_file.read)
        @doc = @original_doc.clone
      end

      def xform(css_specifier, within: doc)
        within.css(css_specifier).each do
          yield _1
        end
      end

      def clone_each(css_specifier, collection, within: doc)
        xform(css_specifier, within: within) do |template_node|
          collection.each do |element|
            cloned_node = template_node.clone
            template_node.before(cloned_node)
            yield cloned_node, element
          end

          template_node.remove
        end
      end

      def recent_posts
        posts.sort_by(&:date).reverse.take(5)
      end
  end
end
