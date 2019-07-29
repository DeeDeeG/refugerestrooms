require 'capybara/rspec'
require 'rspec/rails'
# spec/spec_helper.rb
#

Capybara.register_driver :firefox_headless do |app|
  options = ::Selenium::WebDriver::Firefox::Options.new
  options.args << '--headless'

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.javascript_driver = :firefox_headless

WebMock.disable_net_connect!(allow_localhost: true)


RSpec.configure do |config|
  config.include Locations

  config.before(:each) do
    stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?language=en&latlng=37.8044,-122.2708")
      .with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'})
      .to_return(:status => 200, :body => File.new("#{Rails.root}/spec/fixtures/guess_in_oakland.json"), :headers => {})

    # Akismet response for spam
    stub_request(:post, /.*.rest.akismet.com\/1.1\/comment-check/).
    with(body: /^.*Spam.*$/).
    to_return(status: 200, body: 'true', headers: {})

    # Akismet response for non-spam
    stub_request(:post, /.*.rest.akismet.com\/1.1\/comment-check/).
      with{|request| !request.body.include? "Spam"}.
      to_return(status: 200, body: 'false', headers: {})
  end
end

