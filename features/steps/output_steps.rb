Then /^the output must contain "([^"]+)"$/ do |content|
  assert_partial_output content, all_output
end

Then /^the output must be empty$/ do
  assert_exact_output '', all_output
end

Then /^the output must be aruba current directory$/ do
  assert_exact_output File.expand_path(current_dir), all_output.chomp
end
