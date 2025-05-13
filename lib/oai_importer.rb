# Imports records from an OAI-PMH source.
require_relative "utils/ead"

class OaiImporter < Importer
  include Utils::Ead

  RECORD_ACTIVE = "active"
  RECORD_DELETED = "deleted"
  RECORD_FAILED = "failed"

  def import(&block)
    return unless source.collections.any?

    source.client.list_identifiers(metadata_prefix: source.metadata_prefix).full.each do |header|
      status = header.status
      status = (status.to_s == RECORD_DELETED) ? RECORD_DELETED : RECORD_ACTIVE

      record_identifier = header.identifier
      collection = get_collection(record_identifier)
      next unless collection

      datestamp = header.datestamp
      record = create_record(collection, record_identifier, status, datestamp)
      next unless should_process?(record, datestamp)

      process_record(collection, record, datestamp)
      yield record if block_given?
    end
  end

  private

  def process_record(collection, record, datestamp)
    oai_record = fetch_record(record.identifier)
    ead_element = extract_ead(oai_record.metadata)
    corpname = extract_repository_name(ead_element)

    if collection.requires_owner? && !collection.is_owner?(corpname)
      record.update(status: RECORD_FAILED, message: "Owner mismatch: #{corpname} vs #{collection.name}")
      return
    end

    eadid = find_ead_identifier(ead_element)
    eadid = eadid.gsub(/\s/, ".") if eadid.present?
    attributes = build_record_attributes(datestamp, corpname, eadid)
    update_record(record, xml_to_string(ead_element), attributes)
  rescue => e
    record.update(status: RECORD_FAILED, message: e.message)
  end

  def get_collection(record_identifier)
    collection_identifier = parse_identifier(record_identifier)
    source.collections.where(identifier: collection_identifier).first
  end

  def parse_identifier(identifier)
    return nil unless identifier

    if (match = identifier.match(%r{(/repositories/\d+)}))
      match[1]
    end
  end

  def create_record(collection, record_identifier, status, datestamp)
    record = collection.records.find_or_create_by(
      collection: collection,
      identifier: record_identifier
    ) do |r|
      r.modification_date = datestamp
      r.status = status
    end
    record.update(status: status) if record.status != status
    record
  end

  def should_process?(record, datestamp)
    return false unless record.active?

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
end
