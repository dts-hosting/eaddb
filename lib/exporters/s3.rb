module Exporters
  class S3 < Base
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
