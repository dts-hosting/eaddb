class Sources::ArchivesSpace < Source
  def run
    ArchivesSpaceGetRecordsJob.perform_later(self)
  end
end