module Cucumber
  module SSHD
    class Server
      include Aruba::Api

      HOST              = 'some_host.test'
      PORT              = 2222
      COMMAND           = '/usr/sbin/sshd'
      COMMAND_ARGS      = '-Deq'
      KEY_PATH          = 'etc/ssh_host_rsa_key'
      KEY_PUB_PATH      = KEY_PATH.dup << '.pub'
      SSHD_CONFIG_PATH  = 'etc/sshd_config'
      SSH_CONFIG_PATH   = '.ssh/config'

      attr_accessor :base_path, :host, :port, :pid

      def initialize(base_path, wait_ready: false)
        @base_path  = base_path
        @host       = ENV['SSHD_TEST_HOST'] ? ENV['SSHD_TEST_HOST'] : HOST
        @port       = ENV['SSHD_TEST_PORT'] ? ENV['SSHD_TEST_PORT'] : PORT
        @pid        = nil
        @wait_ready = wait_ready
      end

      def command
        "#{COMMAND} -f #{SSHD_CONFIG_PATH} #{COMMAND_ARGS}"
      end

      def wait_ready?
        !!@wait_ready
      end

      def start
        in_current_dir do
          @pid = fork do
            $stderr.reopen '/dev/null'
            exec command
          end
        end

        wait_ready! if wait_ready?
      end

      def wait_ready!
        TCPSocket.new 'localhost', port
      rescue Errno::ECONNREFUSED
        sleep 0.05
        retry
      end

      def stop
        Process.kill('TERM', pid)
        Process.wait(pid)
      end

      def make_env
        %w[etc .ssh].map { |e| create_dir e }

        write_file KEY_PATH, <<-eoh
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA7EVDKeM7NYCGGVJw0wWLGCoptMFSR7DobhbEx2bAQbWDLFBF
7S9bXpW/ddebFA4GBkHVriNPwu/IGjIgO3tivVcy6iguNKdYRABlSfpeAs+OdCzK
hyEWhmKnFMZs2MhPiJg/KUep2gFZLoEcs9vkk37+cLcuUVkXVOSPXlYCuHjgkwaN
9ij/KvCcLP4tw83H3Pyh1Wn/Y4k1+3nWN2S3RgRHF9RjEx7nm2FmXcZq1wygPe5G
2bQNvZKykL+wlKIHwKiM4AWpVClczOiljNv9KROhGWanIZNNBIDTnikxFvY0FyoP
1qvRrE8BlqxNeyG/vYNmXsv8xpO0MOF65z3d2QIDAQABAoIBAHL8dmZxX0R3i0vR
knUwsnQNOQTuPPQFBelmDViaCiEwjGlJm+6F6KrMqERarO+Cr63l5m98YfoWJkWR
dZxdPT22rWHGMk6PzuYxZxoszgoCJ2skzWAcW1EFvBjhROHwAr0Qk1Ssut4NX/DB
B04FS2X5HS2QCOuwNymqnpejtmk+A2hv9bGVzj0X614gX3h5+0dImGrYE0Lu+Abf
5fvWhN5nxgK5CVlU7WM09WxyHj9lBXI+W2dgTl6w3QJfBBQTkarLmDpwIeErq9xc
al2qHj60nYC+RdFopuLfJWKiObdKRFpuPFYKbTA9nJz9T61zAF+LaDZ1mvdTuQmz
jJEJ0nECgYEA+o2uJcDOCD2LBp2LqeQcGk1PrFLpSQ5921B10SxDWhygs2+UlBCW
7t/qurqjEUZ91l3TAlUM7ViB/EkXk/xWJRJCzlmWRXfht9LPQTWlnDox/w8uSV2g
3VwPx1xpju2PHO7Vsk6dsQsyoro14qNhYa9m1lBHA1TtJ/RLWauvnmUCgYEA8WgZ
MthPXi/clDg2DlROGOEWd7WgaErEz578HWnegcMrHb8RV/XW21CO2UegHykzUlxz
vJxAqhQeKJbP7T8uzuCZnkZqBqPh5PJT1XqxZibTeQvqYLzbIiKqmDrZWuRJvbLL
kPxwYEG8R8nl9Dk1tLHuTQWWa5Q49he1cDss4GUCgYEA7WMBRZnIW3xb1Xe9VMjg
a3cmbqHbj7FgQ0OXbQigA6euBnRIdITHTCnxDtw4Fe0Q2uLoQoRsjA/YkDx8T2S8
BcGodDPjMYxk2rKsVR9L+poUtpEejLpd6H0KIhwHkzi26HXNGHRt6ckvP4hn94RO
hqwWJiXHMnvrenh2T85fxRUCgYEA7m06NhWejhAHc/zwpsZtO/VUE3e3rknqiIUl
zIc71D3G3+JOZunQA1xVOhSb+SrgHYBibu6Ej3a/MqeBRXkZ6gm6r7AsF9LU0SLl
2fsMKzA9vVgfbNwaMmS6yQ+WjUbb7hghJlmtQ+So6N5n2AaJHKaADmJuZmJGwAg6
k1ZexGECgYAFc+GjjFOPxC+Qg6z8261PnDffBK0o+0/EIq3cGA7Cp5pEo/hhMjDl
W7CLjAGkok9W+rr9XwwXWCBuJmPh2jYeNaQljrHt9hIAOAxoYdbweb9oSo5SkcHv
iDjcFK8S1e5vnlZAh9xH1WMCEsaz1WNqWm7CZOayN2LFn6Ed9seYYg==
-----END RSA PRIVATE KEY-----
        eoh

        write_file KEY_PUB_PATH, <<-eoh
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDsRUMp4zs1gIYZUnDTBYsYKim0wVJHsOhuFsTHZsBBtYMsUEXtL1telb9115sUDgYGQdWuI0/C78gaMiA7e2K9VzLqKC40p1hEAGVJ+l4Cz450LMqHIRaGYqcUxmzYyE+ImD8pR6naAVkugRyz2+STfv5wty5RWRdU5I9eVgK4eOCTBo32KP8q8Jws/i3Dzcfc/KHVaf9jiTX7edY3ZLdGBEcX1GMTHuebYWZdxmrXDKA97kbZtA29krKQv7CUogfAqIzgBalUKVzM6KWM2/0pE6EZZqchk00EgNOeKTEW9jQXKg/Wq9GsTwGWrE17Ib+9g2Zey/zGk7Qw4XrnPd3Z
        eoh

        write_file SSHD_CONFIG_PATH, <<-eoh
Port #{port}
ListenAddress ::1

Protocol 2
HostKey #{File.expand_path base_path}/#{KEY_PATH}
PidFile /dev/null
UsePrivilegeSeparation no
Subsystem sftp /usr/libexec/sftp-server
ForceCommand HOME=#{File.expand_path base_path} sh -c "cd ~; $SSH_ORIGINAL_COMMAND"
        eoh

        write_file SSH_CONFIG_PATH, <<-eoh
Host        #{host}
  HostName  localhost
  Port      #{port}
        eoh
      end
    end
  end
end
