module Destinations
  class GitRepository < Destination
    attribute :username, :string, default: "x-access-token"
    validates :username, :password, presence: true

    def ok_to_run?
      username.present? && password.present? && transfers.any?
    end

    def self.display_name
      "Git"
    end

    def self.version
      # TODO: gem "git"
    end

    private

    def perform_run(transfer_ids = nil)
      raise NotImplementedError
    end
  end
end
