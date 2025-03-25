namespace :export do
  task :destination, [:id] => :environment do |_t, args|
    destination = Destination.find(args[:id])
    exporter = ArcLightExporter.new(destination)
    exporter.export
  end
end
