ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require_relative "support/test_constants"
require "rails/test_help"
require "webmock/minitest"

module ActiveSupport
  class TestCase
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
