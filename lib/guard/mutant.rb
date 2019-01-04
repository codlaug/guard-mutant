require "guard/mutant/version"
require 'guard/compat/plugin'

require 'mutant'

module Guard
  class Mutant < Plugin
    
    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      super
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
      puts "I started!"
      run_all
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    def stop
      puts "I stopped!"
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
      puts "I reloaded!"
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
      puts "HWEKRWEKR"
      cli = ::Mutant::CLI.call(["-r", "./config/environment", "--use", "rspec", "Foo"])
      puts cli.inspect
      bootstrap = ::Mutant::Env::Bootstrap.call(cli)
      puts bootstrap.inspect
      ::Mutant::Runner.call(bootstrap)
      puts "I'm running them all!"
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    def run_on_additions(paths)
      puts "Something was added!"
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    def run_on_modifications(paths)
      puts "Something was modified!"
      puts "PATHS!!!!!!  " + paths.inspect
      # mod = Module.new do
      $CLASS_NAMES = []
      # paths.each do |path|
      #   # modul = load(path)
      #   # $LOAD_PATH << '.'
      #   # $:.unshift Dir.getwd
      #   Kernel.class_exec do
      #     def require_relative(file)
      #       puts __FILE__.inspect
      #       wd = Dir.getwd
      #       puts "working dir: #{wd}"
      #       fd = File.dirname($__PFILE__)
      #       puts "file dir: #{fd}"
      #       dir = File.join(wd, fd)
      #       puts "dirpath: #{dir}"
      #       realdir = File.realpath(dir)
      #       puts "realdir: #{realdir}"
      #       f = File.join(realdir, file)
      #       puts "final filepath: #{f}"
      #       mod = Module.new do
      #         module_eval(File.read("#{f}.rb"))
      #         $CLASS_NAMES += constants
      #       end
      #     end
      #     def describe
      #       nil
      #     end
      #   end
      #   remove_method :describe
      #   $__PFILE__ = path
      #   $LOAD_PATH << '.'
      #   # puts $LOAD_PATH.inspect
      #   x = class_eval File.read(path)
      #   # puts x.inspect
      # end

      filepaths_to_load = []

      f = File.open(paths[0])
      f.each do |l|
        if l.starts_with? 'require' or l.starts_with? 'require_relative'
          filepaths_to_load << l.split(' ')[1].gsub("'", '')
        end
      end

      # $LOAD_PATH.unshift(File.absolute_path(File.dirname(paths[0])))

      # puts $LOAD_PATH.inspect

      # puts filepaths_to_load.inspect

# ActiveSupport::Dependencies.require_or_load(path)
# ActiveSupport::Dependencies.depend_on(path)

      modules = []

      watch_stack = ActiveSupport::Dependencies::WatchStack.new

      # byebug
      filepaths_to_load.each do |path|
        path = File.join(File.absolute_path(File.dirname(paths[0])), path)
        begin
          # puts "paths " + path
          # puts "depend on " + ActiveSupport::Dependencies.new_constants_in { load(paths[0]) }.inspect
          # puts "loadable constants " + ActiveSupport::Dependencies.loadable_constants_for_path(path).inspect
          modules += ActiveSupport::Dependencies.loadable_constants_for_path(path)
        rescue LoadError => e
          puts e.inspect
          puts 'could not load '+path
        end
      end

      paths.each do |path|
        modules += ActiveSupport::Dependencies.loadable_constants_for_path(path)
      end

      puts modules.inspect
      # end
      # cli = ::Mutant::CLI.call(["-r", "./config/environment", "--use", "rspec", modules.join(' ')])
      # puts "CLI!!!!!!!   " + cli.inspect
      # bootstrap = ::Mutant::Env::Bootstrap.call(cli)
      # puts "BOOTSTRAAP!!!!!!!!    " + bootstrap.inspect
      # ::Mutant::Runner.call(bootstrap)

      command = "bundle exec mutant -r ./config/environment --use rspec Foo"
      pid = Kernel.spawn({}, command) # use spawn to stub in JRuby
      result = ::Process.wait2(pid)
      puts result.inspect
      puts "I'm running the modified ones"
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    def run_on_removals(paths)
      puts "Something was removed!"
    end
    
  end
end
