module Statue
  class Build
    class Config
      value_semantics do
        output_dir AbsolutePathname, coerce: Pathname.method(:new)
        once? Bool(), default: true
      end
    end

    attr_reader :config

    def initialize(config)
      @config = config
      @build_count = 0
    end

    def call
      FileUtils.mkdir_p(output_dir)

      puts "Input: #{input_dir}"
      puts "Output: #{output_dir}"
      loop do
        build
        break if config.once?
        sleep(2)
      rescue Interrupt
        puts "Interrupt received"
        break
      end
      puts "Done"
    end

    private

      def build
        start_time = Time.now
        puts ">>> Building ".ljust(80, '>')
        puts "  Input: #{input_dir}"

        # TODO: smarter handling of outputs, watch for file changes
        inputs = FileSet.new(input_dir)
        outputs = Outputs.for(inputs)
        existing_outputs = FileSet.new(output_dir)

        # write outputs
        filter(outputs).each { write(_1, _2, existing_outputs) }

        # remove existing outputs that shouldn't exist anymore
        existing_outputs
          .reject { outputs.key?(_1.path) }
          .each { delete(_1) }

        build_frontend # needs to come after HTML is output

        puts "<<< Finished building in #{(Time.now - start_time).round(3)} seconds"

        @build_count += 1
      end

      def output_dir
        config.output_dir
      end

      def input_dir
        Statue::INPUT_DIR
      end

      # This is a bit of a hack, for now. It should be a proper build output,
      # instead of custom code that runs after all the outputs. It needs to run
      # after the HTML is generated so that Tailwind can do tree shaking.
      def build_frontend
        puts "  Building frontend"
        system("yarn build-prod", chdir: input_dir/'frontend')
        FileUtils.cp(input_dir/'frontend/dist/main.css', output_dir/'style.css')
      end

      def write(path, output, existing_outputs)
        if should_write?(output, existing_outputs[path])
          puts "  #{output.description} #{path}"
          full_path = output_dir / path
          assert_output_path!(full_path)
          FileUtils.mkdir_p(full_path.dirname)
          full_path.open('wb') do |f|
            output.write_to(f)
          end
        else
          # puts "  Skipping #{path}"
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
        file.delete
      end

      def assert_output_path!(path)
        unless path.descendant_of?(output_dir)
          fail "Not an output path: #{path}"
        end
      end

      def filter(outputs)
        return outputs

        keys = [
          'index.html',
        ].map { Pathname(_1) }
        outputs.slice(*keys)
      end
  end
end
