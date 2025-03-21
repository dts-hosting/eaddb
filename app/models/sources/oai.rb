class Sources::Oai < Source
  def build_validation_url
    "#{url}?verb=Identify"
  end

  def run
    OaiGetRecordsJob.perform_later(self)
  end
end
