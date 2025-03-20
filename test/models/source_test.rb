require "test_helper"

class SourceTest < ActiveSupport::TestCase
  include TestConstants::Endpoints

  setup do
    ARCHIVES.values.each do |url|
      stub_request(:head, url).to_return(status: 200)
    end
  end

  test "valid source" do
    source = Source.new(
      type: "Sources::ArchivesSpace",
      name: "Test Source",
      url: "https://test.archivesspace.org/staff/api",
      username: "user",
      password: "pass"
    )
    assert source.valid?
  end

  test "requires name" do
    source = Source.new(url: "https://test.archivesspace.org/staff/api")
    assert_not source.valid?
    assert_includes source.errors[:name], "can't be blank"
  end

  test "requires url" do
    source = Source.new(name: "Test Source")
    assert_not source.valid?
    assert_includes source.errors[:url], "can't be blank"
  end

  test "validates url format" do
    source = Source.new(
      name: "Test Source",
      url: "not_a_url"
    )
    assert_not source.valid?
    assert_includes source.errors[:url], "must be a valid URL"

    source.url = "ftp://test.archivesspace.org"
    assert_not source.valid?
    assert_includes source.errors[:url], "must be a valid URL"
  end

  test "validates url connectivity" do
    stub_request(:head, "https://good-url.com/").to_return(status: 200)
    stub_request(:head, "https://bad-url.com/").to_return(status: 404)
    stub_request(:head, "https://error-url.com/").to_raise(SocketError)

    source = Source.new(name: "Test", url: "https://good-url.com")
    assert source.valid?

    source.url = "https://bad-url.com"
    assert_not source.valid?
    assert_includes source.errors[:url], "returned invalid response code: 404"

    source.url = "https://error-url.com"
    assert_not source.valid?
    assert_match /is not accessible/, source.errors[:url].first
  end

  test "should validate uniqueness of url scoped to name" do
    original = Source.create!(
      type: "Sources::ArchivesSpace",
      name: "Test Source",
      url: "https://test.archivesspace.org/staff/api",
      username: "user",
      password: "pass"
    )

    duplicate = Source.new(
      type: "Sources::ArchivesSpace",
      name: original.name,
      url: original.url,
      username: "different_user",
      password: "different_pass"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:url], "and name combination already exists"

    # Test that different name allows same URL
    duplicate.name = "Demo Source"
    assert duplicate.valid?

    # Test that different URL allows same name
    duplicate.name = original.name
    duplicate.url = "https://demo.archivesspace.org/staff/api"
    assert duplicate.valid?
  end

  test "encrypts username and password" do
    source = Source.create!(
      type: "Sources::ArchivesSpace",
      name: "Test",
      url: "https://test.archivesspace.org/staff/api",
      username: "admin",
      password: "admin"
    )

    assert_equal "admin", source.username
    assert_equal "admin", source.password
  end

  test "username and password are optional" do
    source = Source.new(
      type: "Sources::Oai",
      name: "Test Source",
      url: "https://test.archivesspace.org/oai"
    )
    assert source.valid?
  end

  test "handles urls with paths properly" do
    stub_request(:head, "https://test.archivesspace.org/staff/api/").
      to_return(status: 200)

    source = Source.new(
      name: "Test Source",
      url: "https://test.archivesspace.org/staff/api"
    )
    assert source.valid?
  end

  test "handles network timeouts" do
    stub_request(:head, "https://slow-server.com/").
      to_raise(Timeout::Error)

    source = Source.new(
      name: "Test Source",
      url: "https://slow-server.com"
    )
    assert_not source.valid?
    assert_match /is not accessible/, source.errors[:url].first
  end
end
