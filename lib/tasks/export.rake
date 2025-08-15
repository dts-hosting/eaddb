namespace :export do
  task batch: :environment do
    SendRecordsToDestinationsJob.perform_later
  end

  task :destination, [:id] => :environment do |_t, args|
    destination = Destination.find(args[:id])
    SendRecordsJob.perform_later(destination)
  end
end
