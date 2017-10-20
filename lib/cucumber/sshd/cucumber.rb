require 'cucumber/sshd/server'

Before '@sshd' do
  start_server = -> do
    Cucumber::SSHD::Server.start \
      home:       ENV.fetch('CUCUMBER_SSHD_HOME', 'tmp/home'),
      addr:       ENV.fetch('CUCUMBER_SSHD_LISTEN', '::1'),
      port:       ENV.fetch('CUCUMBER_SSHD_PORT', 2222),
      debug:      ENV.key?('CUCUMBER_SSHD_DEBUG'),
      persist:    ENV.key?('CUCUMBER_SSHD_PERSIST'),
      wait_ready: ENV.key?('CUCUMBER_SSHD_WAIT_READY')
  end

  if !$_sshd && ENV.key?('CUCUMBER_SSHD_PERSIST')
    $_sshd = start_server.call
    at_exit { $_sshd.stop }
  elsif !$_sshd
    $_sshd = start_server.call
  else
    $_sshd.configure
    $_sshd.start unless ENV.key? 'CUCUMBER_SSHD_PERSIST'
  end
end

After '@sshd' do
  $_sshd.stop unless ENV.key? 'CUCUMBER_SSHD_PERSIST'
end
