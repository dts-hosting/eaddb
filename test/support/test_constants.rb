module TestConstants
  module Endpoints
    BASE_DEMO_URL = "demo.archivesspace.org"
    BASE_TEST_URL = "test.archivesspace.org"

    ARCHIVES = {
      base_api: "https://#{BASE_TEST_URL}/api/version",
      base_oai: "https://#{BASE_TEST_URL}/oai?verb=Identify",
      demo_api: "https://#{BASE_DEMO_URL}/staff/api/version",
      test_api: "https://#{BASE_TEST_URL}/staff/api/version"
    }
  end
end
