namespace :crud do
  namespace :create do
    task :api_source, ["name", "url", "username", "password"] => :environment do |_t, args|
      source = Source.create!(
        type: "Sources::Api",
        name: args.name,
        url: args.url,
        username: args.username,
        password: args.password
      )
      puts source.to_json
    end

    task :collection, ["source_id", "name", "identifier"] => :environment do |_t, args|
      collection = Collection.create!(
        source_id: args.source_id,
        name: args.name,
        identifier: args.identifier
      )
      puts collection.to_json
    end

    task :destination_arclight, ["collection_id", "name", "url", "identifier", "config"] => :environment do |_t, args|
      raise "Config file not found" unless File.exist?(args.config)

      config = args.config
      destination = Destinations::ArcLight.new(
        collection_id: args.collection_id,
        name: args.name,
        url: args.url,
        identifier: args.identifier
      )
      destination.config.attach(io: File.open(config), filename: File.basename(config))
      destination.save!

      puts destination.to_json
    end

    task :oai_source, ["name", "url"] => :environment do |_t, args|
      source = Sources::Oai.create!(
        name: args.name,
        url: args.url
      )
      puts source.to_json
    end

    task :user, ["email_address", "password"] => :environment do |_t, args|
      user = User.create!(
        email_address: args.email_address,
        password: args.password
      )
      puts user.to_json
    end
  end

  namespace :delete do
    # TODO
  end
end
