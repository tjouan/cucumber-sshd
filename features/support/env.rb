require 'childprocess'
require 'cucumber/sshd/cucumber'

After do
  if File.exist? @_sshd.base_path
    FileUtils.remove_entry_secure @_sshd.base_path
  end
end
