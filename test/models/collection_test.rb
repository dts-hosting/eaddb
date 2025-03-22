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

  test "cannot create collection with duplicate name for same source" do
    source = sources(:oai)
    Collection.create!(
      name: "Test Collection 1",
      source: source,
      identifier: "/repositories/1"
    )

    duplicate = Collection.new(
      name: "Test Collection 1",
      source: source,
      identifier: "/repositories/2"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "can create collections with same name for different sources" do
    source1 = sources(:oai)
    source2 = sources(:archives_space)

    Collection.create!(
      name: "Test Collection 1",
      source: source1,
      identifier: "/repositories/4"
    )

    collection = Collection.new(
      name: "Test Collection 1",
      source: source2,
      identifier: "/repositories/4"
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

  test "cannot create collection with duplicate identifier for same source" do
    source = sources(:oai)
    Collection.create!(
      name: "First Collection",
      source: source,
      identifier: "/repositories/1"
    )

    duplicate = Collection.new(
      name: "Second Collection",
      source: source,
      identifier: "/repositories/1"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:identifier], "has already been taken"
  end

  test "can create collections with same identifier for different sources" do
    source1 = sources(:oai)
    source2 = sources(:archives_space)

    Collection.create!(
      name: "First Collection",
      source: source1,
      identifier: "/repositories/1"
    )

    collection = Collection.new(
      name: "Second Collection",
      source: source2,
      identifier: "/repositories/1"
    )

    assert collection.valid?
  end

  test "can save existing collection without triggering uniqueness validation" do
    collection = collections(:oai)
    assert collection.valid?
    assert collection.save
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
        modification_date: Time.zone.today,
        ead_xml: fixture_file_upload("test/fixtures/files/sample.xml", "application/xml")
      )
    end
  end
end
