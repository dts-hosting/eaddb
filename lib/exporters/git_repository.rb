module Exporters
  class GitRepository < Base
    def export
      raise NotImplementedError
    end

    def withdraw
      raise NotImplementedError
    end

    def self.reset(destination)
      raise NotImplementedError
    end
  end
end
