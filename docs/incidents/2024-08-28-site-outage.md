# Site Outage

## What happened?

- 2024-08-28
  - 09:?? - Opportunistic maintenance to remove stale container images in production began.
  - 09:30 - The frontend microservice that provides the user-facing website became unavailable (HTTP 5xx responses).
  - 15:?? - Admin attempts to use the website and notices that it is unavailable.
  - 15:?? - Admin logs into production, notices that the frontend service is failing due to a lack of container images.
  - 15:?? - Admin rebuilds and redeploys the latest copy of the frontend microservice.
  - 15:45 - Availability of the frontend microservice was restored.

## What went wrong?

- Essential current container images were removed from production.
- Lack of system uptime monitoring caused a delay identifying the outage.

## What went well?

- The system's Search API remained available throughout the website outage.

## Prevention Measures

**Operational Processes**

There are a small number of semi-manual operational processes that our team already performs on a regular basis, such as rotation of certificates.

Non-trivial processes should be documented, and stale container image cleanup is a good candidate for documentation.

**Alerting**

We discontinued automated alerting for the service in May of Y2021, and the team has expressed a preference not to use automated alerting.

The recommended action here is to remind the team to regularly check the status of the site when they feel comfortable to; we will not add automated alerting at this time.
