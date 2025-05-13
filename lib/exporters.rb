module Exporters
  class Base
    attr_reader :destination

    def initialize(destination)
      @destination = destination
    end

    def export(transfer_ids = nil, &block)
      raise NotImplementedError
    end

    def reset
      raise NotImplementedError
    end
  end
end
