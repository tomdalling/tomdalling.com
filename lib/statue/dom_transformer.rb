module Statue
  class DOMTransformer
    def initialize(document)
      @stack = [document]
    end

    # override in subclass
    def setup(**kwargs)
      unless kwargs.empty?
        raise NoMethodError, "#{self.class}##{__method__} not implemented for given params"
      end
    end

    # override in subclass
    def transform
      raise NoMethodError, "#{self.class}##{__method__} is not implemented"
    end

    private

      def document
        @stack.first
      end

      def current_node
        @stack.last
      end

      def with_current_node(node)
        @stack.push(node)
        yield(node)
      ensure
        @stack.pop
      end

      def at(css_specifier, text=nil, **attrs)
        found = current_node.css(css_specifier.to_s)
        if found.size == 1
          with_current_node(found.first) do |n|
            text!(text) if text
            attrs!(attrs)
            yield(n) if block_given?
          end
          found.first
        elsif found.empty?
          fail "No elements found for: #{css_specifier}"
        else
          fail "Multiple elements found for: #{css_specifier}"
        end
      end

      def at_each(css_specifier, &block)
        current_node.css(css_specifier.to_s).each do
          with_current_node(_1, &block)
        end
      end

      def attrs!(attrs)
        attrs.each { current_node[_1] = _2 }
      end

      def text!(str)
        current_node.content = str
      end

      def prepend_text!(str)
        text!(str + current_node.content)
      end

      def interpolate_text!(substitutions)
        text = current_node.content.dup
        substitutions.each do |(var, value)|
          text["${#{var}}"] = value.to_s
        end
        text!(text)
      end

      def html!(content)
        if content.is_a?(String)
          current_node.inner_html = content
        elsif content.is_a?(Nokogiri::HTML::DocumentFragment)
          current_node.children = content.children
        else
          fail("Can't make HTML from a #{content.class}")
        end
      end

      def remove!
        current_node.remove
      end

      def append!(element_name, text=nil, **attrs)
        el = document.create_element(element_name.to_s)
        current_node << el

        with_current_node(el) do |n|
          text!(text) if text
          attrs!(attrs)
          yield(n) if block_given?
        end
      end

      def clone_each(css_specifier, collection)
        node = at(css_specifier)
        parent = node.parent
        node.remove

        collection.each do |thing|
          new_node = node.clone
          parent << new_node
          with_current_node(new_node) do
            yield thing
          end
        end
      end
  end
end
