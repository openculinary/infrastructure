# Site Outage

## What happened?

- 2023-06-16
  - Dependency update to `CRI-O v1.27` in production.
- 2024-08-??
  - AppArmor problems observed in production system logs: access denied during shutdown of containers.
  - A workflow that involves manual cleanup of containers during deployment is introduced as a workaround.
  - Deployments continue to take place.
  - System log error messages begin to accumulate rapidly -- some of these are the access-denied messages, and some relate to missing resources that have been manually removed.
- 2024-08-10
  - 13:05 Disk space in production is exhausted due to the container teardown/resource reclamation error messages.
  - 13:05 Service outage occurs.
- 2024-08-12
  - 15:45 - The site outage is noticed by operational staff.
  - 15:51 - A reboot is initiated.
  - 16:00 - Disk space is identified as the problem; space is reclaimed and service restoration begins.
  - 16:02 - System recovery is hampered by the fact that redeployments cause further error logging.
  - 16:04 - Given the identification of container log message accumulation as a probable cause of the outage, a decision is made to begin opportunistic upgrades in the hope that these will resolve the problem.
  - 16:08 - Journal/log files are removed to restore disk space.
  - 16:09 - Service recovers, albeit with continuing error messages.
  - 16:12 - Operating system update to `Ubuntu 24.04` begins.
  - 16:58 - Operating system update completed.
  - 16:43 - Container redeployment begins.
  - 17:08 - Container runtime: updated to `CRI-O v1.30`
  - 17:10 - Container redeployments are confirmed to teardown container resources sucessfully.

## What went wrong?

- Lack of system uptime monitoring caused a delay identifying the outage.
- Errors that had been observed and noticed by staff during deployment of containers were ignored.
- A non-scalable manual container cleanup approach was introduced instead of time being taken to identify and resolve a production problem.
- Incompatible AppArmor rules were deployed with the deployed container system/runtime.

## What went well?

- During recovery, the deployment-time container teardown problem was solved (albeit at some risk; outage recovery isn't a great time to upgrade dependencies).

## Prevention Measures

**Storage Configuration**

**Alerting**

**Operational Processes**

**Upgrade Processes**
