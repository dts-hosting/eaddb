# Exports records to and deletes from ArcLight:
# For import we use traject as per the docs (bundle exec) and get
# the EAD mapping configuration from the ArcLight gem.
# For delete we use the Solr API directly.
class ArcLightExporter
  attr_reader :destination

  def initialize(destination)
    @destination = destination
  end

  def export(transfer_ids = nil, &block)
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
        yield transfer if block_given?
      end

      deletes = transfer_ids.nil? ? destination.pending_deletes : destination.pending_deletes.where(id: transfer_ids)
      deletes.find_each do |transfer|
        process_delete(transfer)
        yield transfer if block_given?
      end
    ensure
      repositories_cfg.close
      repositories_cfg.unlink
    end
  end

  def process_delete(transfer)
    uri = URI.parse("#{destination.url}/update?commit=true")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/xml"

    escaped_id = CGI.escapeHTML(transfer.record.ead_identifier).tr(".", "-")

    delete_xml = <<~XML
      <delete>
        <query>_root_:#{escaped_id}</query>
      </delete>
    XML

    request.body = delete_xml

    result = http.request(request)
    if result.is_a?(Net::HTTPSuccess)
      transfer.succeeded!("Deleted record from #{destination.identifier}")
    else
      transfer.failed!("Failed to delete record #{transfer.record.id}: #{result.code} #{result.message}")
    end
  end

  def process_transfer(transfer, indexer_cfg, repositories_cfg)
    transfer.record.ead_xml.open do |xml|
      _, stderr, status = Open3.capture3(command(indexer_cfg, repositories_cfg, xml.path))
      if status.success?
        transfer.succeeded!("Transferred to #{destination.identifier}")
      else
        transfer.failed!("Failed to process: #{first_error(stderr)}")
      end
    end
  rescue => e
    transfer.failed!("Failed to process: #{e.message}")
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
