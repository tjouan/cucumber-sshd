require 'cucumber/sshd/server'

Before('@sshd') do
  make_server = proc do
    server = Cucumber::SSHD::Server.new(current_dir, wait_ready: @_sshd_wait_ready)
    server.make_env
    server.start
    server
  end

  if @_sshd_fast && !@_sshd
    @_sshd = make_server.call
    at_exit { @_sshd.stop }
  else
    @_sshd = make_server.call
  end

  ENV['HOME'] = File.expand_path current_dir
end

After('@sshd') do
  @_sshd.stop unless @_sshd_fast
end
