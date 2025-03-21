# EadDB

Pulls EAD records from sources and passes them on to destinations.

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
- As sources are processed for records a record must be matched to a collection for it to be imported.
- Each collection has zero or more destinations. If zero then records are only stored, not shipped.
- Records are sent to each destination configured for their collection.
