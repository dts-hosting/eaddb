class Sources::Oai < Source
  def run
    OaiGetRecordsJob.perform_later(self)
  end
end