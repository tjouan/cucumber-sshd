require 'childprocess'
require 'cucumber/sshd/cucumber'

After do
  if File.exist? $_sshd.home
    FileUtils.remove_entry_secure $_sshd.home
  end
end
