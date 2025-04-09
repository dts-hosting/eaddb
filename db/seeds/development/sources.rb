return unless Rails.env.development?

User.find_or_create_by!(email_address: "admin@eaddb.org") do |user|
  user.password = "password"
end

source = Sources::Oai.find_or_create_by!(name: "Lyrasis OAI", url: "https://archivesspace.lyrasistechnology.org/oai")
source.collections.find_or_create_by!(name: "LYRASIS Special Collections", identifier: "/repositories/2")
source.collections.find_or_create_by!(name: "LYRASIS Corporate Archive", identifier: "/repositories/4")
