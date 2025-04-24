return unless Rails.env.development?

User.find_or_create_by!(email_address: "admin@eaddb.org") do |user|
  user.password = "password"
end

source = Sources::Oai.find_or_create_by!(name: "Lyrasis OAI", url: "https://archivesspace.lyrasistechnology.org/oai")

[
  {
    name: "LYRASIS Special Collections",
    identifier: "/repositories/2"
  },
  {
    name: "LYRASIS Corporate Archive",
    identifier: "/repositories/4"
  }
].each do |collection_attributes|
  collection = source.collections.find_or_create_by!(collection_attributes)
  collection.destinations.find_or_create_by!(
    type: "Destinations::ArcLight",
    name: collection.name,
    url: "http://localhost:8983/solr/arclight"
  ) do |d|
    d.identifier = collection.name.downcase.gsub(/\s/, "-")
    d.config.attach(
      io: File.open(Rails.root.join("test/fixtures/files/repositories.yml")),
      filename: "repositories.yml",
      content_type: "application/yaml"
    )
  end
end
