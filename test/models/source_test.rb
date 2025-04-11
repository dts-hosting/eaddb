require "test_helper"

class SourceTest < ActiveSupport::TestCase
  setup do
    @source = create_source
    @collection = create_collection(source: @source)
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
    assert_match(/must be a valid/, source.errors[:url].first)
  end

  test "validates url connectivity" do
    stub_request(:head, "https://fail.archivesspace.org/oai?verb=Identify").to_return(status: 404)
    stub_request(:head, "https://timeout.archivesspace.org/oai?verb=Identify").to_raise(Timeout::Error)
    stub_request(:head, "https://error.archivesspace.org/oai?verb=Identify").to_raise(SocketError)

    source = Source.new(type: "Sources::Oai", name: "Test", url: "https://test.archivesspace.org/oai")
    assert source.valid?

    source.url = "https://fail.archivesspace.org/oai"
    assert_not source.valid?
    assert_match(/404/, source.errors[:url].first)

    source.url = "https://timeout.archivesspace.org/oai"
    assert_not source.valid?
    assert_match(/must be a valid resolvable URL/, source.errors[:url].first)

    source.url = "https://error.archivesspace.org/oai"
    assert_not source.valid?
    assert_match(/must be a valid resolvable URL/, source.errors[:url].first)

    source = Source.new(
      type: "Sources::ArchivesSpace",
      name: "Test Source",
      url: "https://test.archivesspace.org/staff/api"
    )
    assert source.valid?
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

    duplicate.name = "Demo Source"
    assert duplicate.valid?

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

  test "total_records_count updates when records are added or removed" do
    assert_difference -> { @source.reload.total_records_count }, 1 do
      @collection.records.create!(
        identifier: "new-record",
        modification_date: Time.zone.today,
        ead_xml: fixture_file_upload("test/fixtures/files/sample.xml", "application/xml")
      )
    end

    assert_difference -> { @source.reload.total_records_count }, -1 do
      @collection.records.first.destroy
    end
  end

  test "total_records_count updates when collection is added or removed" do
    new_collection = @source.collections.create!(
      name: "New Collection",
      identifier: "/repositories/4"
    )

    new_collection.records.create!(
      identifier: "new-record",
      modification_date: Time.zone.today,
      ead_xml: fixture_file_upload("test/fixtures/files/sample.xml", "application/xml")
    )

    assert_equal 1, new_collection.reload.records_count
    assert_equal @source.collections.sum(:records_count), @source.reload.total_records_count

    assert_difference -> { @source.reload.total_records_count }, -1 do
      new_collection.destroy
    end
  end

  test "cannot destroy source with existing collections" do
    assert_no_difference "Source.count" do
      @source.destroy
    end

    assert @source.persisted?

    assert_includes @source.errors[:base], "Cannot delete source while collections exist."
  end

  test "can destroy source after collections are removed" do
    @source.collections.destroy_all

    assert_difference "Source.count", -1 do
      @source.destroy
    end

    assert @source.destroyed?
  end
end
