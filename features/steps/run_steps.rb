When /^I run "([^"]+)" remotely$/ do |command|
  run_simple "ssh -F .ssh/config some_host.test #{command}", true
end

When /^I run "([^"]+)" sftp command remotely$/ do |command|
  run_simple "sh -c 'echo #{command} | sftp -F .ssh/config some_host.test'", true
end
