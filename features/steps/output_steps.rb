def prepare_output
  @ssh.io.stdout.rewind
  yield @ssh.io.stdout.read
end


Then /^the output must contain "([^"]+)"$/ do |content|
  prepare_output do |output|
    expect(output).to include content
  end
end

Then /^the output must be empty$/ do
  prepare_output do |output|
    expect(output).to be_empty
  end
end

Then /^the output must be the server base path$/ do
  prepare_output do |output|
    expect(output.chomp).to eq File.expand_path $_sshd.home
  end
end
