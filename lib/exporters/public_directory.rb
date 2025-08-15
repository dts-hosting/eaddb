# Exports records to and deletes from the Rails public folder. Use for testing.
# Format: public_dir / ead / destination.identifier / record.ead_identifier
# This exporter has no external dependencies.
module Exporters
  class PublicDirectory < Base
    PUBLIC_EAD_DIRECTORY = Rails.public_path.join("ead")

    def export
      FileUtils.mkdir_p(export_path)
      File.write(File.join(export_file), record.ead_xml.download)
      transfer.succeeded!("Copied to #{export_file}")
    end

    def withdraw(transfer)
      FileUtils.rm_f(export_file)
      transfer.succeeded!("Deleted record #{export_file}")
    end

    def self.reset(destination)
      FileUtils.rm_rf(File.join(PUBLIC_EAD_DIRECTORY, destination.identifier))
    end

    private

    def export_file
      File.join(export_path, "#{record.ead_identifier}.xml")
    end

    def export_path
      File.join(PUBLIC_EAD_DIRECTORY, destination.identifier)
    end
  end
end
