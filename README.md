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
./bin/rake "crud:create:collection[1,Lyrasis Special Collections,/repositories/2]"
./bin/rake "crud:create:collection[1,Lyrasis Corporate Archive,/repositories/4]"

D_NAME="Lyrasis Special Collections"
D_ARC_URL=http://localhost:8983/solr/blacklight-core
D_ARC_ID=lyrasis-special-collections
D_CFG_FILE=test/fixtures/files/repositories.yml
./bin/rake "crud:create:destination_arclight[1,$D_NAME,$D_ARC_URL,$D_ARC_ID,$D_CFG_FILE]"

D_NAME="Lyrasis Corporate Archive"
D_ARC_URL=http://localhost:8983/solr/blacklight-core
D_ARC_ID=lyrasis-corporate-archive
D_CFG_FILE=test/fixtures/files/repositories.yml
./bin/rake "crud:create:destination_arclight[2,$D_NAME,$D_ARC_URL,$D_ARC_ID,$D_CFG_FILE]"
```
