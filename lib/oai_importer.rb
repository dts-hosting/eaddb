# Imports records from an OAI-PMH source, processing only valid records
# that match collection requirements and have been updated since last import.
class OaiImporter
  attr_reader :source
  def initialize(source)
    @source = source
  end

  def import(&block)
    return unless source.collections.any?

    source.client.list_identifiers(metadata_prefix: source.metadata_prefix).full.each do |header|
      status = header.status
      next unless status.nil? # TODO: allow when supporting deletes

      record_identifier = header.identifier
      collection_identifier = parse_identifier(record_identifier)
      collection = source.collections.where(identifier: collection_identifier).first
      next unless collection

      datestamp = header.datestamp
      # TODO: also set record status (active or deleted)
      record = create_record(collection, record_identifier, datestamp)
      next unless should_process?(record, datestamp)

      process_record(collection, record, datestamp)
      yield record if block_given?
    end
  end

  def process_record(collection, record, datestamp)
    oai_record = fetch_record(record.identifier)
    ead_element = extract_ead(oai_record.metadata)
    corpname = extract_repository_name(ead_element)
    return if collection.requires_owner? && !collection.has_owner?(corpname)

    eadid = ensure_eadid(ead_element)
    attributes = build_record_attributes(datestamp, corpname, eadid)
    update_record(record, xml_to_string(ead_element), attributes)
  rescue => e
    Rails.logger.error("Failed to process record #{record.identifier}: #{e.message}")
    Rails.logger.debug(e.backtrace.join("\n"))
  end

  private

  def create_record(collection, record_identifier, datestamp)
    collection.records.find_or_create_by(
      collection: collection,
      identifier: record_identifier
    ) do |r|
      r.modification_date = datestamp
    end
  end

  def should_process?(record, datestamp)
    # return false if record.deleted? # TODO: status "active" (i.e. not deleted record)

    !record.ead_xml.attached? || record.modification_date < datestamp
  end

  def fetch_record(identifier)
    source.client.get_record(
      metadata_prefix: source.metadata_prefix,
      identifier: identifier
    ).record
  end

  def build_record_attributes(datestamp, corpname, eadid)
    {
      ead_identifier: eadid,
      modification_date: datestamp,
      owner: corpname
    }
  end

  def update_record(record, ead_xml, attributes)
    record.ead_xml.attach(
      io: StringIO.new(ead_xml.to_s),
      filename: "ead.xml",
      content_type: "application/xml"
    )
    record.update!(attributes)
  end

  # XML helpers
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

  def parse_identifier(identifier)
    return nil unless identifier

    if (match = identifier.match(%r{(/repositories/\d+)}))
      match[1]
    end
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
