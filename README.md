# EadDB

Retrieves EAD records from sources and sends them on to destinations.

Supported sources:

- ArchivesSpace Api [TODO]
- Oai EAD XML providers

Supported destinations:

- ArcLight
- Git Repository [TODO]
- S3 [TODO]

## Data model

- A source is required to have zero or more collections. If zero then records cannot be retrieved.
- Collections are used to group records by matching with an identifier.
- As sources are processed a record must be matched to a collection for it to be imported.
- Each collection has zero or more destinations. If zero then records are only stored, not shipped.
- Records are sent to each destination configured for their collection.

## Rake tasks

```bash
./bin/rake "crud:create:user[admin@eaddb.org,123456]"
./bin/rake "crud:create:oai_source[Lyrasis Archives,https://archivesspace.lyrasistechnology.org/oai]"

# create collection for source 7 (this assumes db:seeds + new source)
./bin/rake "crud:create:collection[7,Lyrasis Special Collections,/repositories/2]"
./bin/rake "crud:create:collection[7,Lyrasis Corporate Archive,/repositories/4]"

# with 1 source and 2 collections we can now run an import from the source
# sources are processed once but can populate multiple collections
./bin/rake "import:source[7]"

# create 2 destinations
C_ID=7
D_NAME="Lyrasis Special Collections"
D_ARC_URL=http://localhost:8983/solr/arclight
D_ARC_ID=lyrasis-special-collections
D_CFG_FILE=test/fixtures/files/repositories.yml
./bin/rake "crud:create:destination_arclight[$C_ID,$D_NAME,$D_ARC_URL,$D_ARC_ID,$D_CFG_FILE]"

C_ID=8
D_NAME="Lyrasis Corporate Archive"
D_ARC_URL=http://localhost:8983/solr/arclight
D_ARC_ID=lyrasis-corporate-archive
D_CFG_FILE=test/fixtures/files/repositories.yml
./bin/rake "crud:create:destination_arclight[$C_ID,$D_NAME,$D_ARC_URL,$D_ARC_ID,$D_CFG_FILE]"

# send records to the destinations (this requires local ArcLight)
./bin/rake "export:destination[1]"
./bin/rake "export:destination[2]"
```

## Deployment

Remote with Kamal.

```bash
# TODO: download .kamal/secrets.qa

# verify connections to the server
bundle exec kamal server bootstrap -d qa

# verify access to docker registry
bundle exec kamal registry login -d qa

# run the deploy process
bundle exec kamal deploy -d qa

# run a command on the container
bundle exec kamal app exec -d qa "bin/rails about"

# connect to the container
bundle exec kamal app exec -i -d qa "bin/rails console"
```
