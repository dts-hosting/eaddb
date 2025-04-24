class GitRepositoryExporter
  attr_reader :destination

  def initialize(destination)
    @destination = destination
  end

  def export(transfter_ids = nil, &block)
  end
end
