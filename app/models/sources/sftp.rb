module Sources
  class Sftp < Source
    def build_validation_url
      url
    end

    def client
      raise NotImplementedError
    end

    def importer
      Importers::Sftp
    end

    def ok_to_run?
      username.present? && password.present? && collections.any?
    end

    def self.display_name
      "SFTP"
    end
  end
end
