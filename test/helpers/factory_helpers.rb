module FactoryHelpers
  def create_collection(attributes = {})
    defaults = {
      name: "Test Collection #{SecureRandom.hex(4)}",
      identifier: "/repositories/#{rand(10_000)}",
      source: attributes[:source] || create_source
    }
    Collection.create!(defaults.merge(attributes))
  end

  def create_destination(type: :arc_light, attributes: {})
    collection = attributes[:collection] || create_collection

    defaults = {
      name: "Test #{type.to_s.camelize} Destination",
      url: "https://example.com/#{type}",
      identifier: "test-#{type}-#{SecureRandom.hex(4)}",
      collection: collection
    }

    config = nil
    klass = case type
    when :arc_light
      config = fixture_file_upload(
        Rails.root.join("test/fixtures/files/repositories.yml"),
        "application/yaml"
      )
      Destinations::ArcLight
    when :s3_bucket
      Destinations::S3Bucket
    when :git_repository
      Destinations::GitRepository
    else
      raise ArgumentError, "Unknown destination type: #{type}"
    end
    attributes[:config] = config if config

    klass.create!(defaults.merge(attributes))
  end

  def create_record(attributes = {})
    defaults = {
      collection: attributes[:collection] || create_collection,
      identifier: "id-#{SecureRandom.hex(4)}",
      ead_identifier: "ead-id-#{SecureRandom.hex(4)}",
      creation_date: Date.current,
      modification_date: Date.current,
      ead_xml: fixture_file_upload(
        Rails.root.join("test/fixtures/files/sample.xml"),
        "application/xml"
      )
    }
    Record.create!(defaults.merge(attributes))
  end

  def create_source(attributes = {})
    defaults = {
      type: "Sources::Oai",
      name: "Test Source #{SecureRandom.hex(4)}",
      url: "https://test.archivesspace.org/oai"
    }
    Source.create!(defaults.merge(attributes))
  end
end
