module Statue
  class DOMTransform
    def initialize
      @stack = []
    end

    def call(dom, *args, **kwargs, &block)
      with_current_node(dom) do
        transform(*args, **kwargs, &block)
      end
    end

    protected

      # override in subclass
      def transform(...)
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
        fail "#{self.class} did not call `super` in #initialize" unless @stack

        @stack.push(node)
        begin
          yield(node)
        ensure
          @stack.pop
        end
      end

      def at(css_specifier, text=nil, **attrs, &block)
        found = current_node.css(css_specifier.to_s)
        if found.size == 1
          yield_at(found.first, text, attrs, block)
          found.first
        elsif found.empty?
          fail "No elements found for: #{css_specifier}"
        else
          fail "Multiple elements found for: #{css_specifier}"
        end
      end

      def at_each(css_specifier, text=nil, **attrs, &block)
        current_node.css(css_specifier.to_s).each do
          yield_at(_1, text, attrs, block)
        end
      end

      def yield_at(node, text=nil, attrs={}, block)
        with_current_node(node) do
          text!(text) if text
          attrs!(attrs)
          block.(node) if block
        end
      end

      def attrs!(attrs)
        attrs.each { current_node[_1] = _2 }
      end

      def add_classes!(classes)
        existing = (current_node[:class] || '').split
        attrs!(class: (existing + classes).uniq.join(' '))
      end

      def text!(str)
        current_node.content = str
      end

      def prepend_text!(str)
        text!(str + current_node.content)
      end

      def append_text!(str)
        text!(current_node.content + str)
      end

      def interpolate_text!(substitutions)
        text = current_node.content.dup
        substitutions.each do |(var, value)|
          text["${#{var}}"] = value.to_s
        end
        text!(text)
      end

      def html!(content)
        current_node.children = coerce_to_node_set(content)
      end

      def outer_html!(content)
        current_node.replace(coerce_to_node_set(content))
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

      def coerce_to_node_set(content)
        if content.is_a?(String)
          Nokogiri::HTML.fragment(content).children
        elsif content.is_a?(Nokogiri::HTML::DocumentFragment)
          content.children
        else
          fail("Can't make HTML from a #{content.class}")
        end
      end
  end
end
