# RecipeRadar Recommended Storage Configuration

This document contains recommendations to configure hardware for hosting a RecipeRadar application cluster.

In future we hope that storage will be provisioned from a mixture of local devices and peers; at the time of writing, however, a single dedicated host is still recommended for data storage.  Local-and-peer store will not remove the need for thoughtful storage I/O arrangement, but it should obsolete the need for disk-level layout recommendations.

## Considerations

Primarily a RecipeRadar user session requires an accessible recipe search engine, and a thumbnail and icon image cache.  There is a lot of work that must occurs prior to the session -- including crawling and persistence of recipe data -- but once online, the search engine and image cache are key.

Thumnail and icon caching is provided via [imgproxy](https://github.com/imgproxy/imgproxy)'s in-memory cache, with a fallback via an outbound disk-based caching proxy when content is not available.

Search performance is paramount to user experience.  Image load time is important but - at least until we collect statistics that determine whether image cache hit rates are not sufficient to support user experience - to minimize read/write queue conflict with search operations and reduce storage costs we may rely on slower storage for disk-based image content.

## Disk Layout

The following disk layout is recommended:

| I/O Path | Disk Type | Resident Services | Mountpoint | Desired Properties
| --- | --- | --- | --- | ----
| Performance path | Fast SSD >= 50GB | | /mnt/performance | N/A
| | | OpenSearch | | |
| Persistence path | Reliable disks >= 1TB | | /mnt/persistence | Resizable, n+1 redundancy
| | | PostgreSQL | | |
| | | RabbitMQ | | |
| | | Squid | | |
| Ephemeral storage | Commodity disks >= 1TB | | / | N/A
| | | Operating system | | |
| | | Kubernetes runtime | | |
| | | Container storage | | |
| Backup path | TBD | | /mnt/backup | Archived, scalable, high reliability, off-host
| | | Database backups | | |
| Logging path | TBD | | /mnt/logs | Archived, scalable, high reliability, off-host
| | | Application logging | | |
| | | Cluster logging | | |
| | | System logging | | |
