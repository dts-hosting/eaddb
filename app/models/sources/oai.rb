module Sources
  class Oai < Source
    validate :url_must_end_with_oai

    def build_validation_url
      "#{url}?verb=Identify"
    end

    def client
      OAI::Client.new(url)
    end

    def importer
      Importers::Oai
    end

    def ok_to_run?
      collections.any?
    end

    def metadata_prefix
      "oai_ead"
    end

    def self.display_name
      "OAI"
    end

    private

    def url_must_end_with_oai
      return if url.blank? || url.end_with?("/oai")

      errors.add(:url, "must end with '/oai'")
    end
  end
end
