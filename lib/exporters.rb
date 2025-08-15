module Exporters
  class Base
    attr_reader :destination, :record, :transfer

    def initialize(transfer)
      @transfer = transfer
      @destination = transfer.destination
      @record = transfer.record
    end

    # export the record to destination
    def export
      raise NotImplementedError
    end

    def process
      export if transfer.export?
      withdraw if transfer.withdraw?
    end

    # withdraw (delete) record from destination
    def withdraw
      raise NotImplementedError
    end

    # purge all records from destination
    def self.reset(destination)
      raise NotImplementedError
    end
  end
end
