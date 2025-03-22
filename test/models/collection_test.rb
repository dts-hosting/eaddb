require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  def setup
    @source = create_source
    @collection = create_collection(source: @source)
  end

  test "valid collection" do
    collection = Collection.new(
      source: @source,
      name: "Test Collection #{SecureRandom.hex(4)}",
      identifier: "/repositories/#{rand(1000)}"
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
    source = create_source
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
    source1 = create_source
    source2 = create_source

    Collection.create!(
      name: "Test Collection 1",
      source: source1,
      identifier: "/repositories/1"
    )

    collection = Collection.new(
      name: "Test Collection 1",
      source: source2,
      identifier: "/repositories/2"
    )

    assert collection.valid?
  end

  test "identifier format must be valid" do
    @collection.identifier = "invalid"
    refute @collection.valid?
    assert_includes @collection.errors[:identifier], "is invalid"

    @collection.identifier = "/repositories/#{rand(1000)}"
    assert @collection.valid?
  end

  test "cannot create collection with duplicate identifier for same source" do
    source = create_source
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
    source1 = create_source
    source2 = create_source

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
    collection = create_collection
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
        identifier: "/repositories/#{rand(1000)}"
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
        modification_date: Date.current,
        ead_xml: fixture_file_upload("test/fixtures/files/sample.xml", "application/xml")
      )
    end
  end
end
