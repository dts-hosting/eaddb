namespace :export do
  task batch: :environment do
    SendRecordsToDestinationsJob.perform_later
  end

  task :destination, [:id, :record_id] => :environment do |_t, args|
    destination = Destination.find(args[:id])
    record_id = args[:record_id]
    record_ids = record_id ? [record_id] : nil
    exporter = ArcLightExporter.new(destination)
    exporter.export(record_ids)
  end
end
