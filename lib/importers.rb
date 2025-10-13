module Importers
  class Base
    include Ead

    attr_reader :source

    RECORD_ACTIVE = "active"
    RECORD_DELETED = "deleted"
    RECORD_FAILED = "failed"

    def initialize(source)
      @source = source
    end

    # create local records
    def import(&block)
      raise NotImplementedError
    end

    # process records (download and optionally modify ead attached to record)
    def process(record)
      raise NotImplementedError
    end
  end
end
