require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  def setup
    @source = sources(:oai)
    @collection = collections(:oai)
  end

  test "valid collection" do
    collection = Collection.new(
      source: @source,
      name: "Unique Test Collection",
      identifier: "/repositories/2"
    )
    assert collection.valid?
  end

  test "requires source" do
    @collection.source = nil
    refute @collection.valid?
    assert_includes @collection.errors[:source], "must exist"
  end

  test "requires name" do
    @collection.name = nil
    refute @collection.valid?
    assert_includes @collection.errors[:name], "can't be blank"
  end

  test "requires identifier" do
    @collection.identifier = nil
    refute @collection.valid?
    assert_includes @collection.errors[:identifier], "can't be blank"
  end

  test "name must be unique per source" do
    duplicate = @collection.dup
    refute duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "name can be reused in different sources" do
    different_source = sources(:archives_space)
    collection = Collection.new(
      source: different_source,
      name: @collection.name,
      identifier: "/repositories/2"
    )
    assert collection.valid?
  end

  test "identifier format must be valid" do
    @collection.identifier = "invalid"
    refute @collection.valid?
    assert_includes @collection.errors[:identifier], "is invalid"

    @collection.identifier = "/repositories/2"
    assert @collection.valid?
  end

  test "require_owner_in_record defaults to false" do
    collection = Collection.new
    assert_equal false, collection.require_owner_in_record
  end

  test "increments source collections_count on creation" do
    assert_difference -> { @source.reload.collections_count }, 1 do
      Collection.create!(
        source: @source,
        name: "New Collection",
        identifier: "/repositories/2"
      )
    end
  end

  test "decrements source collections_count on destruction" do
    assert_difference -> { @source.reload.collections_count }, -1 do
      @collection.destroy
    end
  end

  test "records_count updates automatically" do
    assert_difference -> { @collection.reload.records_count }, 1 do
      @collection.records.create!(
        identifier: "new-record",
        modification_date: Date.today,
        ead_xml: fixture_file_upload("test/fixtures/files/sample.xml", "application/xml")
      )
    end
  end
end