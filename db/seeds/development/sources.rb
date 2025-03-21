return unless Rails.env.development?

[
  {base_url: "test.archivesspace.org", name: "Test Instance"},
  {base_url: "demo.archivesspace.org", name: "Demo Instance"},
  {base_url: "sandbox.archivesspace.org", name: "Sandbox Instance"}
].each do |instance|
  archivesspace_url = "https://#{instance[:base_url]}/staff/api"
  Rails.logger.debug { "Creating #{instance[:name]} source: #{archivesspace_url}" }

  Sources::ArchivesSpace.find_or_create_by!(
    name: "#{instance[:name]} ArchivesSpace",
    url: archivesspace_url
  ) do |source|
    source.username = "admin",
      source.password = "admin"
  end

  oai_url = "https://#{instance[:base_url]}/oai"
  Rails.logger.debug { "Creating #{instance[:name]} OAI source: #{oai_url}" }

  Sources::Oai.find_or_create_by!(
    name: "#{instance[:name]} OAI",
    url: oai_url
  )
end
