Given /^a file named ([^ ]+) with:$/ do |path, content|
  File.write File.join($_sshd.home, path), content
end
