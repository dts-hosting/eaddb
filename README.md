# EadDB

Pulls (EAD) records from sources and passes them on to destinations:

- A source is required to have zero or more collections.
- When a source is being processed for records a record must be matched to a collection.
- Each collection has zero or more destinations.
- Records belonging to a collection are sent to each destination configured for that collection.
