Given /^a file named ([^ ]+) with:$/ do |path, content|
  File.write File.join(@_sshd.base_path, path), content
end
