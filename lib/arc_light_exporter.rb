# Exports records to ArcLight using traject as per the docs (bundle exec)
# and getting the EAD mapping configuration from the ArcLight gem directly
class ArcLightExporter
  attr_reader :destination

  def initialize(destination)
    @destination = destination
  end

  def export(transfer_ids = nil)
    arclight_dir = Gem::Specification.find_by_name("arclight").gem_dir
    indexer_cfg = File.join(arclight_dir, "lib", "arclight", "traject", "ead2_config.rb")
    repositories = YAML.safe_load(destination.config.download)

    unless repositories.key?(destination.identifier)
      Rails.logger.error("Repository #{destination.identifier} not found in #{repositories.keys}")
      return
    end

    repositories_cfg = Tempfile.new(["destination_", destination.id.to_s, ".yml"])
    begin
      repositories_cfg.write(repositories.to_yaml)
      repositories_cfg.flush

      transfers = transfer_ids.nil? ? destination.pending_transfers : destination.pending_transfers.where(id: transfer_ids)
      transfers.find_each do |transfer|
        process_transfer(transfer, indexer_cfg, repositories_cfg.path)
      end

      # TODO: deletes = delete_ids.nil? ? destination.pending_deletes : destination.pending_deletes.where(id: delete_ids)
      # deletes.find_each do |transfer|
      #   process_delete(transfer)
      # end
    ensure
      repositories_cfg.close
      repositories_cfg.unlink
    end
  end

  def process_transfer(transfer, indexer_cfg, repositories_cfg)
    transfer.record.ead_xml.open do |xml|
      _, stderr, status = Open3.capture3(command(indexer_cfg, repositories_cfg, xml.path))
      if status.success?
        transfer.succeeded!
      else
        error_message = "Failed to process transfer #{transfer.id}: #{first_error(stderr)}"
        Rails.logger.error(error_message)
        transfer.failed!(error_message)
      end
    end
  rescue => e
    error_message = "Failed to process transfer #{transfer.id}: #{e.message}"
    Rails.logger.error(error_message)
    transfer.failed!(error_message)
  end

  private

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

  def first_error(text)
    error_content = "UNKNOWN ERROR"
    if /ERROR/i.match?(text)
      lines = text.lines
      error_start_idx = lines.find_index { |line| line.include?("ERROR") }

      if error_start_idx
        error_lines = []
        i = error_start_idx

        while i < lines.size && !lines[i].strip.empty?
          error_lines << lines[i]
          i += 1
        end

        error_content = error_lines.join
      end
    end
    error_content
  end
end
