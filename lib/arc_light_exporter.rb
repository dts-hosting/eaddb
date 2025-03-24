class ArcLightExporter
  attr_reader :destination

  def initialize(destination)
    @destination = destination
  end

  def command(indexer_cfg, repositories_cfg, ead_xml)
    <<~CMD
      REPOSITORY_FILE=#{repositories_cfg} \
      REPOSITORY_ID=#{destination.identifier} bundle exec traject \
      -u #{destination.url} \
      -i xml \
      -c #{indexer_cfg} \
      -s processing_thread_pool=0 \
      -s solr_writer.batch_size=1 \
      -s solr_writer.thread_pool=0 \
      #{ead_xml}
    CMD
  end

  def export
    arclight_dir = Gem::Specification.find_by_name("arclight").gem_dir
    indexer_config = File.join(arclight_dir, "lib", "arclight", "traject", "ead2_config.rb")

    destination.transfers.where.not(status: "succeeded").find_each do |transfer|
      if transfer.record.ead_identifier.blank?
        error_message = "Record #{transfer.record.id} has no EAD ID"
        Rails.logger.error(error_message)
        transfer.failed!(error_message)
        next
      end

      destination.config.open do |repositories|
        transfer.record.ead_xml.open do |xml|
          output = `#{command(indexer_config, repositories.path, xml.path)}`
          if $?.success?
            transfer.succeeded!
          else
            error_message = "Failed to process transfer #{$?.exitstatus}: #{output}"
            Rails.logger.error(error_message)
            transfer.failed!(error_message)
          end
        end
      end
    rescue => e
      error_message = "Failed to process transfer #{transfer.id}: #{e.message}"
      Rails.logger.error(error_message)
      transfer.failed!(error_message)
    end
  end
end
