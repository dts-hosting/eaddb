namespace :import do
  task :source, [:id] => :environment do |_t, args|
    source = Source.find(args[:id])
    importer = OaiImporter.new(source)
    importer.import
  end
end
