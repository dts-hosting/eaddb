# Exports records to and withdraws from ArcLight.
# For import we use traject as per the docs (bundle exec) and get
# the EAD mapping configuration from the ArcLight gem.
# For withdraw (delete) we use the Solr API directly.
module Exporters
  class ArcLight < Base
    attr_reader :arclight_dir, :indexer_cfg

    def initialize(transfer)
      super
      @arclight_dir = Gem::Specification.find_by_name("arclight").gem_dir
      @indexer_cfg = File.join(arclight_dir, "lib", "arclight", "traject", "ead2_config.rb")
    end

    def export
      create_repositories_config do |repositories_cfg|
        record.ead_xml.open do |xml|
          _, stderr, status = Open3.capture3(command(indexer_cfg, repositories_cfg, xml.path))
          if status.success?
            transfer.succeeded!("Transferred to #{destination.identifier}")
          else
            transfer.failed!("Failed to process: #{first_error(stderr)}")
          end
        end
      end
    end

    def withdraw
      escaped_id = CGI.escapeHTML(record.ead_identifier).tr(".", "-")
      delete_xml = <<~XML
        <delete>
          <query>_root_:#{escaped_id}</query>
        </delete>
      XML

      response = self.class.delete_request(destination, delete_xml)
      if response.is_a?(Net::HTTPSuccess)
        transfer.succeeded!("Deleted record from #{destination.identifier}")
      else
        transfer.failed!("Failed to delete record: #{response.code} #{response.message}")
      end
    end

    def self.reset(destination)
      delete_xml = "<delete><query>repository_ssim:\"#{destination.repository_name}\"</query></delete>"
      response = delete_request(destination, delete_xml)
      unless response.is_a?(Net::HTTPSuccess)
        raise "Failed to reset Solr: #{response.code} #{response.message}"
      end
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

    def create_repositories_config
      config_hash = Digest::SHA256.hexdigest(destination.repositories.to_yaml)
      filename = "destination_#{destination.id}_#{config_hash}.yml"
      filepath = Rails.root.join("tmp", filename)
      unless File.exist?(filepath) && file_content_matches?(filepath, destination.repositories.to_yaml)
        File.write(filepath, destination.repositories.to_yaml)
      end

      yield filepath
    end

    def file_content_matches?(filepath, expected_content)
      File.read(filepath) == expected_content
    rescue Errno::ENOENT
      false
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

    def self.delete_request(destination, body)
      uri = URI.parse("#{destination.url}/update?commit=true")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "text/xml"

      request.body = body
      http.request(request)
    end

    private_class_method :delete_request
  end
end
