module TestConstants
  module Endpoints
    BASE_TEST_URL = "test.archivesspace.org"
    BASE_DEMO_URL = "demo.archivesspace.org"

    ARCHIVES = {
      port_21: "http://#{BASE_TEST_URL}:21",
      oai: "https://#{BASE_TEST_URL}/oai",
      demo_api: "https://#{BASE_DEMO_URL}/staff/api",
      test_api: "https://#{BASE_TEST_URL}/staff/api",
      api: "https://#{BASE_TEST_URL}/api"
    }
  end
end