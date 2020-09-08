module Statue
  class PageTemplate
    attr_reader :doc

    def initialize
      @doc = File.open(TEMPLATES_DIR / 'page.html') { Nokogiri::HTML(_1) }
    end

    def call(page)
      if page.canonical_url
        at_css('head').add_child('<link />').tap do
          _1[:rel] = "canonical"
          _1[:href] = page.canonical_url
        end
      end

      xform('title') do
        _1.content = page.title + _1.content
      end

      xform('main') do
        _1.inner_html = page.html_content
      end

      posts = [] # TODO: need to get posts
      clone_each('ul.recent-posts li', posts.take(5)) do |node, post|
        xform('a', within: node) do
          _1.content = post.title
          _1[:href] = post.url_path
        end
      end

      # [:ul.archives :li]
      # (clone-for [[yearmonth posts] (post/archived all-posts)]
      #            [:a] (set-attr :href (post/archive-uri yearmonth))
      #            [:.month] (content (str (unparse-yearmonth yearmonth)))
      #            [:.post-count] (content (str (count posts))))

      # [:ul.categories :li]
      # (clone-for [[cat posts] (post/categorized all-posts)]
      #            [:a.category] (do-> (set-attr :href (category/uri cat))
      #                                (content (:name cat)))
      #            [:a.feed] (set-attr :href (category/feed-uri cat))
      #            [:.post-count] (content (str (count posts))))

      xform('.current-year') do
        _1.content = Date.today.year
      end

      doc.to_html
    end

    private

      def xform(css_specifier, within: doc)
        within.css(css_specifier).each do
          yield _1
        end
      end

      def clone_each(css_specifier, collection, within: doc)
        xform(css_specifier, within: within) do |template_node|
          collection.each do |element|
            cloned_node = template_node.clone
            template_node.after(cloned_node)
            yield cloned_node, element
          end

          template_node.remove
        end
      end
  end
end
