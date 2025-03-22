class Sources::Oai < Source
  validate :url_must_end_with_oai

  def build_validation_url
    "#{url}?verb=Identify"
  end

  def client
    OAI::Client.new(url)
  end

  def metadata_prefix
    "oai_ead"
  end

  def run
    OaiGetRecordsJob.perform_later(self)
  end

  private

  def url_must_end_with_oai
    return if url.blank? || url.end_with?("/oai")

    errors.add(:url, "must end with '/oai'")
  end
end
