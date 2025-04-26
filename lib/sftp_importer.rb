class SftpImporter
  attr_reader :source

  def initialize(source)
    @source = source
  end

  def import(&block)
  end
end
