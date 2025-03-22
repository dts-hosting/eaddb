class Sources::ArchivesSpace < Source
  validate :url_must_end_with_api

  def build_validation_url
    "#{url}/version"
  end

  def client
    raise NotImplementedError
  end

  def run
    ArchivesSpaceGetRecordsJob.perform_later(self)
  end

  private

  def url_must_end_with_api
    return if url.blank? || url.end_with?("/api")

    errors.add(:url, "must end with '/api'")
  end
end
