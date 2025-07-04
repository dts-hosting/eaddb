module Sources
  class ArchivesSpace < Source
    validate :url_must_end_with_api

    def build_validation_url
      "#{url}/version"
    end

    def client
      raise NotImplementedError
    end

    def importer
      Importers::ArchivesSpace
    end

    def ok_to_run?
      username.present? && password.present? && collections.any?
    end

    def self.display_name
      "ArchivesSpace"
    end

    private

    def url_must_end_with_api
      return if url.blank? || url.end_with?("/api")

      errors.add(:url, "must end with '/api'")
    end
  end
end
