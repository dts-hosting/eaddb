ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require_relative "helpers/factory_helpers"
require_relative "helpers/test_constants"

require "rails/test_help"
require "webmock/minitest"

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ["chromedriver.storage.googleapis.com", "127.0.0.1", "localhost"]
)

WebMock.globally_stub_request do |request|
  matches_archive = TestConstants::Endpoints::ARCHIVES.any? do |archive_url|
    request.uri.to_s.start_with?(archive_url)
  end

  if matches_archive && request.method == :head
    {status: 200}
  elsif request.uri.to_s.match?("https://example.*verb=Identify") && request.method == :head
    {status: 200}
  end
end

module ActiveSupport
  class TestCase
    include ActionDispatch::TestProcess
    include FactoryHelpers

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def sign_in(user)
      post session_url, params: {
        email_address: user.email_address,
        password: "password"
      }
    end
  end
end
