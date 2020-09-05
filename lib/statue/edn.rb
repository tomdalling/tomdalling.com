module Statue
  module EDN
    extend self

    def read(scanner)
      Parser.new(scanner).read
    end

    class Parser
      def initialize(scanner)
        @scanner = scanner
      end

      def read
        skip_whitespace

        case peek
        when '{' then read_map
        when ':' then read_keyword
        when '"' then read_string
        when '[' then read_vector
        when /[a-z]/i then read_var
        when nil then fail!("Expected to read value")
        else fail!("Unhandled value")
        end
      end

      def skip_whitespace
        @scanner.skip(/[ \r\n\t,]*/)
      end

      def read_map
        {}.tap do |result|
          scan!('{')
          loop do
            skip_whitespace
            break if scan('}')
            key = read
            value = read
            result[key] = value
          end
        end
      end

      def read_keyword
        scan!(':')
        scan!(/[a-z_\-?]+/).to_sym
      end

      def read_string
        ''.tap do |result|
          scan!('"')
          loop do
            break if scan('"')
            ch = getch
            result << ch
          end
        end
      end

      def read_var
        var = scan!(/[a-z]+/i)
        case var
        when 'true' then true
        when 'false' then false
        when 'nil' then nil
        else fail!("Unrecognised var: #{var}")
        end
      end

      private

        def scan!(pattern)
          scan(pattern) or fail!("Expected #{pattern}")
        end

        def scan(pattern)
          @scanner.scan(pattern)
        end

        def getch
          @scanner.getch
        end

        def peek
          @scanner.peek(1)
        end

        def fail!(msg)
          raise "#{msg} at #{@scanner.peek(20).inspect}..."
        end
    end
  end
end
