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
      #{ead_xml}
    CMD
  end

  def export
    arclight_dir = Gem::Specification.find_by_name("arclight").gem_dir
    indexer_config = File.join(arclight_dir, "lib", "arclight", "traject", "ead2_config.rb")

    destination.transfers.where.not(status: "succeeded").find_each do |transfer|
      # TODO: we need to add config to destination (for arclight: repositories.yml file)
      destination.config.open do |repositories|
        # TODO: update transfer to have message/s
        transfer.record.ead_xml.open do |xml|
          output = `#{command(indexer_config, repositories.path, xml.path)}`
          if $?.success?
            transfer.succeeded!
          else
            Rails.logger.error("Failed to process transfer #{$?.exitstatus}: #{output}")
            transfer.failed!
          end
        end
      end
    rescue => e
      Rails.logger.error("Failed to process transfer #{transfer.id}: #{e.message}")
      transfer.failed!
    end
  end
end
