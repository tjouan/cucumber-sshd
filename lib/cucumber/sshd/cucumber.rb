require 'cucumber/sshd/server'

Before('@sshd') do
  @_sshd = Cucumber::SSHD::Server.new(current_dir,
    wait_ready: @_sshd_wait_ready
  )
  @_sshd.make_env
  @_sshd.start

  ENV['HOME'] = File.expand_path current_dir
end

After('@sshd') do
  @_sshd.stop
end
