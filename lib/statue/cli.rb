module Statue
  module CLI
    extend self

    def run(argv=ARGV)
      FileUtils.mkdir_p(Statue::OUTPUT_DIR)

      watcher = Watcher.new(Statue::INPUT_DIR)
      tree = Tree.new

      puts "Watching #{watcher.dir}"
      loop do
        process_changes(watcher, tree)
        sleep(1)
      rescue Interrupt
        puts "Interrupt!"
        break
      end

      puts "Done"
    end

    private

      def process_changes(watcher, tree)
        changeset = watcher.next_changeset
        return if changeset.empty?

        puts "== Updating ".ljust(80, '=')
        puts "Changes:"
        changeset.changes.each do
          puts "  #{_1.type} #{_1.path.relative_path_from(watcher.dir)}"
        end

        puts "Actions:"
        tree.actions_for(changeset).each do |action|
          puts "  #{action.description}"
          action.(Statue::OUTPUT_DIR)
        end
      end
  end
end
