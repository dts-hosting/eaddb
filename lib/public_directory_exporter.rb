# Exports records to and deletes from the Rails public folder.
# Format: public_dir / ead / destination.identifier / record.ead_identifier
# This exporter has no external dependencies.
class PublicDirectoryExporter < Exporter
  PUBLIC_EAD_DIRECTORY = Rails.public_path.join("ead")

  def export(transfer_ids = nil, &block)
    FileUtils.mkdir_p(export_path)

    transfers = transfer_ids.nil? ? destination.pending_transfers : destination.pending_transfers.where(id: transfer_ids)
    transfers.find_each do |transfer|
      process_transfer(transfer)
    end

    deletes = transfer_ids.nil? ? destination.pending_deletes : destination.pending_deletes.where(id: transfer_ids)
    deletes.find_each do |transfer|
      process_delete(transfer)
    end
  end

  def reset
    FileUtils.rm_rf(export_path)
  end

  private

  def process_delete(transfer)
    file_path = export_file(transfer)
    FileUtils.rm_f(file_path)
    transfer.succeeded!("Deleted record #{file_path}")
  rescue => e
    transfer.failed!("Failed to delete record: #{e.message}")
  end

  def process_transfer(transfer)
    file_path = export_file(transfer)
    File.write(File.join(file_path), transfer.record.ead_xml.download)
    transfer.succeeded!("Copied to #{file_path}")
  rescue => e
    transfer.failed!("Failed to copy: #{e.message}")
  end

  def export_file(transfer)
    File.join(export_path, "#{transfer.record.ead_identifier}.xml")
  end

  def export_path
    File.join(PUBLIC_EAD_DIRECTORY, destination.identifier)
  end
end
