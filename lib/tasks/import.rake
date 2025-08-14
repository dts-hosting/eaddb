namespace :import do
  task batch: :environment do
    GetRecordsFromSourcesJob.perform_later
  end

  task :source, [:id] => :environment do |_t, args|
    source = Source.find(args[:id])
    GetRecordsJob.perform_later(source)
  end
end
