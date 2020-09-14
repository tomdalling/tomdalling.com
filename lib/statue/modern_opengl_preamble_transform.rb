module Statue
  class ModernOpenGLPreambleTransform < DOMTransform
    def transform(node)
      is_first = !!node['first-article']
      machine_name = node.content

      if is_first
        at('.builds-on-previous') { remove! }
      end

      at('.source_folder code') { append_text!(machine_name) }
      at('.source_folder') { current_node[:href] += machine_name }
    end
  end
end
