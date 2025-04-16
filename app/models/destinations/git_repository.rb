module Destinations
  class GitRepository < Destination
    def ok_to_run?
      username.present? && password.present? && transfers.any?
    end

    def run(transfer_ids = nil)
      raise NotImplementedError
    end

    def self.display_name
      "Git"
    end

    def self.version
      # TODO: gem "git"
    end
  end
end
