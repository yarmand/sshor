
require 'fileutils'

require 'guard/guard'

module ::Guard
  class Sshor < ::Guard::Guard
    # Initialize a Guard.
    # @param [Array<Guard::Watcher>] watchers the Guard file watchers
    # @param [Hash] options the custom Guard options
    def initialize(watchers = [], options = {})
      @ssh_host = options[:ssh_host]
      @socks_port = options[:socks_port]
      @logfilename = options[:logfilename]
      @data_folder = options[:data_folder]
      super
    end

    # Call once when Guard starts. Please override initialize method to init stuff.
    # @raise [:task_has_failed] when start has failed
    def start
      log "sshor starts of host: #{hostname}"
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    # @raise [:task_has_failed] when stop has failed
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    # @raise [:task_has_failed] when reload has failed
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    # @raise [:task_has_failed] when run_all has failed
    def run_all
    end

    # Called on file(s) modifications that the Guard watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_changes(paths)
      paths.each do |f|
        puts "==> #{f}"
        return unless f =~ /#{hostname}/
        kill_connection
        return FileUtils.rm(f) unless f =~ /open/
        user =  File.readlines(f).first.chop
        port = 8100 + Random.rand(100)
        open_connection port
        create_connections_script port, user
        FileUtils.rm f
      end
    end

    # Called on file(s) deletions that the Guard watches.
    # @param [Array<String>] paths the deleted files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    def run_on_removals(paths)
    end

    def pidfile
      data_file('ssh.pid')
    end

    def connection_file
      data_file('connection.sh')
    end

    def kill_connection
      if File.exists? pidfile
        log "##### close connection from #{hostname} to #{@ssh_host}"
        pid =  File.readlines(pidfile).first.to_i
        log "   pid: #{pid}"
        Process.kill "QUIT", pid
        FileUtils.rm pidfile
        FileUtils.rm connection_file
      end
    end

    def open_connection(port)
      log "##### open connection from #{hostname} to #{@ssh_host}"
      log "   port: #{port}"
      fork do
        File.open(pidfile,'w') { |f| f.puts(Process.pid)}
        log "   pid: #{Process.pid}"
        system "ssh -fN -R #{port}:localhost:22 #{@ssh_host}"
      end
    end

    def create_connections_script(port, user)
      connection_script=connection_file
      log "   create connection script #{connection_script}"
      File.open(connection_script,'w') do |fc|
        fc.puts "ssh -fN -L #{port}:localhost:#{port} #{@ssh_host}"
        fc.puts "echo '### establishing connection to #{hostname}'"
        fc.puts "echo '    socks proxy on port: #{@socks_port}'"
        fc.puts "ssh -D #{@socks_port} -p #{port} #{user}@localhost"
      end
    end

    def log(msg)
      logfile.puts("[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{msg}")
      puts msg
    end

    def logfile
      @logfile ||= File.open(@logfilename, 'a')
    end

    def data_file(name)
      File.expand_path("#{@data_folder}/#{hostname}-#{name}")
    end

    def hostname
      @hostname ||= `hostname`.chop.gsub(/\..*$/,'')
    end
  end
end

guard :sshor , :data_folder => 'tunnel', :ssh_host => '-p 17150 action@euw1.actionbox.io' , :socks_port => 8033, :logfilename => 'sshor.log' do
  watch(%r{^tunnel/.*-open$})
  watch(%r{^tunnel/.*-close$})
end

