require "test_helper"
require_relative "system/authentication_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include AuthenticationHelper
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
