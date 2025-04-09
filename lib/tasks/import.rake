namespace :import do
  task batch: :environment do
    GetRecordsFromSourcesJob.perform_later
  end

  task :source, [:id] => :environment do |_t, args|
    source = Source.find(args[:id])
    importer = OaiImporter.new(source)
    importer.import
  end
end
