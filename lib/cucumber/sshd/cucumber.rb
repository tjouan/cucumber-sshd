require 'cucumber/sshd/server'

Before '@sshd' do
  start_server = -> home do
    Cucumber::SSHD::Server.start home, wait_ready: @_sshd_wait_ready
  end

  if @_sshd_fast && !$_sshd
    unless $_sshd
      $_sshd = start_server.call @_sshd_home
      at_exit { $_sshd.stop }
    end
    @_sshd = $_sshd
  else
    @_sshd = start_server.call @_sshd_home
  end
end

After '@sshd' do
  @_sshd.stop unless @_sshd_fast
end
