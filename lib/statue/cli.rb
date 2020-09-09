module Statue
  class CLI
    def self.run(argv=ARGV)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv
      @build_count = 0
    end

    def run
      FileUtils.mkdir_p(output_dir)

      puts "Input: #{input_dir}"
      puts "Output: #{output_dir}"
      loop do
        build
        break if @argv.include?('--once')
      rescue Interrupt
        puts "Interrupt received"
      end
      puts "Done"
    end

    private

      def build
        start_time = Time.now
        puts ">>> Building ".ljust(80, '>')
        puts "  Input: #{input_dir}"

        # TODO: smarter handling of outputs, watch for file changes
        inputs = FileSet.new(Statue::INPUT_DIR)
        outputs = Outputs.for(inputs)
        existing_outputs = FileSet.new(Statue::OUTPUT_DIR)

        # write outputs
        outputs.each { write(_1, _2, existing_outputs) }

        # remove existing outputs that shouldn't exist anymore
        existing_outputs
          .reject { outputs.key?(_1.path) }
          .each { delete(_1) }

        puts "<<< Finished building in #{(Time.now - start_time).round(3)} seconds"

        @build_count += 1
      end

      def output_dir
        # TODO: get this from config/cli
        Statue::OUTPUT_DIR
      end

      def input_dir
        # TODO: get this from config/cli
        Statue::INPUT_DIR
      end

      def write(path, output, existing_outputs)
        if should_write?(output, existing_outputs[path])
          puts "  #{output.description} #{path}"
          full_path = output_dir / path
          assert_output_path!(full_path)
          FileUtils.mkdir_p(full_path.dirname)
          output.write_to(full_path)
        else
          puts "  Skipping #{path}"
        end
      end

      def should_write?(output, existing_file)
        (
          first_build? ||
          existing_file.nil? ||
          output.modified_since?(existing_file.last_modified_at)
        )
      end

      def first_build?
        @build_count == 0
      end

      def delete(file)
        assert_output_path!(file.full_path)
        puts "  Deleting #{file.path}"
        file.full_path.delete
      end

      def assert_output_path!(path)
        unless path.descendant_of?(output_dir)
          fail "Not an output path: #{path}"
        end
      end
  end
end
