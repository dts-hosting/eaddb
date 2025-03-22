# Imports records from an OAI-PMH source, processing only valid records
# that match collection requirements and have been updated since last import.
class OaiImporter
  attr_reader :source
  def initialize(source)
    @source = source
  end

  def extract_repository_name(xml_element)
    return nil if xml_element.nil?

    REXML::XPath.first(xml_element, "//repository/corpname")&.text
  end

  def import
    source.client.list_identifiers(metadata_prefix: source.metadata_prefix).full.each do |header|
      status = header.status
      next unless status.nil?

      record_identifier = header.identifier
      collection_identifier = parse_identifier(record_identifier)
      collection = source.collections.where(identifier: collection_identifier).first
      next unless collection

      datestamp = header.datestamp
      process_record(collection, record_identifier, datestamp)
    end
  end

  def parse_identifier(identifier)
    return nil unless identifier

    if (match = identifier.match(%r{(/repositories/\d+)}))
      match[1]
    end
  end

  def process_record(collection, record_identifier, datestamp)
    existing_record = collection.records.where(identifier: record_identifier).first
    return unless should_process?(existing_record, datestamp)

    record = fetch_record(record_identifier)
    ead_xml = record.metadata.write("")
    corpname = extract_repository_name(record.metadata)
    return if collection.require_owner_in_record && corpname != collection.owner

    attributes = build_record_attributes(record_identifier, datestamp)
    existing_record ? update_record(existing_record, ead_xml, attributes) : create_record(collection, ead_xml, attributes)
  rescue => e
    Rails.logger.error("Failed to process record #{record_identifier}: #{e.message}")
    Rails.logger.debug(e.backtrace.join("\n"))
  end

  private

  def should_process?(existing_record, datestamp)
    existing_record.nil? || existing_record.modification_date < datestamp
  end

  def fetch_record(identifier)
    source.client.get_record(
      metadata_prefix: source.metadata_prefix,
      identifier: identifier
    ).record
  end

  def build_record_attributes(record_identifier, datestamp)
    {
      identifier: record_identifier,
      modification_date: datestamp
    }
  end

  def update_record(existing_record, record, attributes)
    attach_ead_xml(existing_record, record)
    existing_record.update!(attributes)
  end

  def create_record(collection, record, attributes)
    new_record = Record.new(attributes.merge(collection: collection))
    attach_ead_xml(new_record, record)
    new_record.save!
  end

  def attach_ead_xml(record_instance, xml_content)
    record_instance.ead_xml.attach(
      io: StringIO.new(xml_content.to_s),
      filename: "ead.xml",
      content_type: "application/xml"
    )
  end
end
