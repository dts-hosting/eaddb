module Importers
  class Base
    attr_reader :source

    def initialize(source)
      @source = source
    end

    def import(&block)
      raise NotImplementedError
    end
  end
end
