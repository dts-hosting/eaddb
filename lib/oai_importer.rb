# Imports records from an OAI-PMH source, processing only valid records
# that match collection requirements and have been updated since last import.
class OaiImporter
  attr_reader :source
  def initialize(source)
    @source = source
  end

  def ensure_eadid(xml_element)
    return if xml_element.nil?

    eadid = extract_eadid(xml_element)
    return eadid if eadid

    unitid = xml_text_value(xml_element, "//ead/archdesc/did/unitid")
    return nil if unitid.nil?

    eadid_element = REXML::XPath.first(xml_element, "//eadheader/eadid")

    if eadid_element
      eadid_element.text = unitid
    else
      eadheader = REXML::XPath.first(xml_element, "//eadheader")
      if eadheader
        eadid_element = REXML::Element.new("eadid")
        eadid_element.text = unitid
        eadheader.add_element(eadid_element)
      else
        return nil
      end
    end

    unitid
  end

  def extract_ead(xml_element)
    return if xml_element.nil?

    xml_element.elements["/metadata/ead"] || xml_element.elements["//ead"]
  end

  def extract_eadid(xml_element)
    xml_text_value(xml_element, "//eadheader/eadid")
  end

  def extract_repository_name(xml_element)
    xml_text_value(xml_element, "//repository/corpname")
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
    ead_element = extract_ead(record.metadata)
    corpname = extract_repository_name(ead_element)
    return if collection.require_owner_in_record && corpname != collection.owner

    eadid = ensure_eadid(ead_element)
    attributes = build_record_attributes(record_identifier, datestamp, corpname, eadid)
    ead_content = xml_to_string(ead_element)
    if existing_record
      update_record(existing_record, ead_content, attributes)
    else
      create_record(collection, ead_content, attributes)
    end
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

  def build_record_attributes(record_identifier, datestamp, corpname, eadid)
    {
      identifier: record_identifier,
      ead_identifier: eadid,
      modification_date: datestamp,
      owner: corpname
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

  def xml_text_value(xml_element, xpath)
    return if xml_element.nil?

    REXML::XPath.first(xml_element, xpath)&.text
  end

  def xml_to_string(xml_element)
    return if xml_element.nil?

    xml = ""
    formatter = REXML::Formatters::Pretty.new(0)
    formatter.compact = true
    formatter.write(xml_element, xml)
  end
end
