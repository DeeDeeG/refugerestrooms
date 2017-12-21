When(/^I search for "(.*?)"$/) do |search|
  fill_in 'search', with: search
  find('.submit-search-button').click
end

When(/^I search from (.*?)$/) do |location|
  mock_location location
  find('.current-location-button').click
end

Then(/^the search buttons should have ARIA labels$/) do
  expect(page).to have_button(class: 'submit-search-button', aria-label: => 'Search')
  expect(page).to have_button(class: 'current-location-button', aria-label: => 'Search by Current Location')
end
