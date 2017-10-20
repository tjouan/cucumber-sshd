require 'tempfile'

def run command
  @ssh = ChildProcess.build *command
  @ssh.cwd = @_sshd.base_path
  @ssh.io.stdout = Tempfile.new File.basename $0 + ?_
  @ssh.io.stderr = Tempfile.new File.basename $0 + ?_
  @ssh.start
  @ssh.wait
end


When /^I run "([^"]+)" remotely$/ do |command|
  run %w[ssh -F .ssh/config some_host.test] + [command]
end

When /^I run "([^"]+)" sftp command remotely$/ do |command|
  run [
    'sh',
    '-c',
    "echo #{command} | sftp -F .ssh/config some_host.test"
  ]
end


Then /^the command must terminate successfully$/ do
  expect(@ssh.exit_code).to eq 0
end
