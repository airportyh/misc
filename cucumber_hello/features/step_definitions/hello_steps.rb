what_you_say = nil

Given /^that I told you to say "(.*)"$/ do |thing|
  what_you_say = thing
end

Then /^I should see "([^\"]*)"$/ do |thing|
  if thing != what_you_say then
    raise 'Error'
  end
end
