module TestConstants
  module Endpoints
    BASE_DEMO_URL = "demo.archivesspace.org"
    BASE_TEST_URL = "test.archivesspace.org"

    ARCHIVES = [
      "https://#{BASE_TEST_URL}/api/version",
      "https://#{BASE_TEST_URL}/api?verb=Identify",
      "https://#{BASE_TEST_URL}/oai?verb=Identify",
      "https://#{BASE_DEMO_URL}/staff/api/version",
      "https://#{BASE_TEST_URL}/staff/api/version",
      "https://#{BASE_TEST_URL}/staff/version",
    ]
  end
end
