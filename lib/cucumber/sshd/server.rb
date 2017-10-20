module Cucumber
  module SSHD
    class Server
      BASE_PATH             = 'tmp/home'.freeze
      HOST                  = 'some_host.test'.freeze
      HOSTNAME              = 'localhost'.freeze
      LISTEN_ADDR           = '::1'.freeze
      PORT                  = 2222
      COMMAND               = '/usr/sbin/sshd'.freeze
      COMMAND_ARGS          = '-Deq'.freeze
      KEY_PATH              = 'etc/ssh_host_rsa_key'.freeze
      KEY_PUB_PATH          = [KEY_PATH, '.pub'].join.freeze
      SSHD_CONFIG_PATH      = 'etc/sshd_config'.freeze
      SSH_CONFIG_PATH       = '.ssh/config'.freeze
      SSH_KNOWN_HOSTS_PATH  = '.ssh/known_host'.freeze
      SFTP_SERVER_PATHS     = %w[
        /usr/libexec/sftp-server
        /usr/lib/openssh/sftp-server
      ].freeze

      KEY = <<-eoh.freeze
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIJbQy3yg9iU4xFvia9DWKWuhMzI5QGncR6OUldAOSIe7oAoGCCqGSM49
AwEHoUQDQgAEJpS8Sknl2X6PNurToQCNu5lX/scaJLr3FkiufD+p67epbwIjiyzo
qnLMVQddVitzQP7LEhXbNUuUAzEMfA6rAA==
-----END EC PRIVATE KEY-----
      eoh
      KEY_PUB =
        'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNT' \
        'YAAABBBCaUvEpJ5dl+jzbq06EAjbuZV/7HGiS69xZIrnw/qeu3qW8CI4ss6KpyzFUH' \
        'XVYrc0D+yxIV2zVLlAMxDHwOqwA='

      class << self
        def start *args
          server = new args.shift, *args
          server.configure
          server.start
          server
        end
      end

      attr_accessor :base_path, :host, :addr, :port, :pid

      def initialize base_path, wait_ready: false
        @base_path  = base_path || BASE_PATH
        @host       = HOST
        @addr       = ENV.fetch 'CUCUMBER_SSHD_LISTEN', LISTEN_ADDR
        @port       = ENV.fetch 'CUCUMBER_SSHD_PORT', PORT
        @pid        = nil
        @wait_ready = wait_ready
      end

      def configure
        %w[etc .ssh].map { |e| create_dir_secure e }
        configure_server
        configure_client
      end

      def start
        Dir.chdir base_path do
          @pid = fork do
            $stderr.reopen '/dev/null' unless ENV.key? 'CUCUMBER_SSHD_DEBUG'
            exec command
          end
          if ENV.key? 'CUCUMBER_SSHD_DEBUG'
            sleep 0.05
            fail "`#{command}` failed" if Process.waitpid pid, Process::WNOHANG
          end
        end

        wait_ready! if wait_ready?
      end

      def stop
        Process.kill 'TERM', pid
        Process.wait pid
      end

    private

      def command
        [
          COMMAND,
          '-f',
          SSHD_CONFIG_PATH,
          COMMAND_ARGS
        ].join ' '
      end

      def configure_client
        write_file_secure SSH_CONFIG_PATH, <<-eoh
Host                    #{host}
  HostName              #{HOSTNAME}
  Port                  #{port}
  UserKnownHostsFile    #{File.expand_path base_path}/#{SSH_KNOWN_HOSTS_PATH}
        eoh
        write_file_secure SSH_KNOWN_HOSTS_PATH, "[#{HOSTNAME}]:2222 #{KEY_PUB}"
      end

      def configure_server
        write_file_secure KEY_PATH, KEY
        write_file_secure KEY_PUB_PATH, KEY_PUB
        write_file_secure SSHD_CONFIG_PATH, <<-eoh
Port #{port}
ListenAddress #{addr}
Protocol 2
HostKey #{File.expand_path base_path}/#{KEY_PATH}
PidFile /dev/null
UsePrivilegeSeparation no
Subsystem sftp #{sftp_server_path}
ForceCommand HOME=#{File.expand_path base_path} sh -c "cd ~; [ -f .ssh/rc ] && . .ssh/rc; $SSH_ORIGINAL_COMMAND"
        eoh
      end

      def create_dir_secure path
        FileUtils.mkdir_p File.join(base_path, path), mode: 0700
      end

      def sftp_server_path
        SFTP_SERVER_PATHS.detect { |e| File.exist? e }
      end

      def wait_ready!
        TCPSocket.new HOSTNAME, port
      rescue Errno::ECONNREFUSED
        sleep 0.05
        retry
      end

      def wait_ready?
        !!@wait_ready
      end

      def write_file_secure path, content
        File.open File.join(base_path, path), ?w, 0600 do |file|
          file.write content
        end
      end
    end
  end
end
