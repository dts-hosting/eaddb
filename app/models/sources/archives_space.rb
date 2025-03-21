class Sources::ArchivesSpace < Source
  def build_validation_url
    "#{url}/version"
  end

  def run
    ArchivesSpaceGetRecordsJob.perform_later(self)
  end
end
