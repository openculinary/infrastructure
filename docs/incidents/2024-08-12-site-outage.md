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
  - 13:05 - Disk space in production is exhausted due to the container teardown/resource reclamation error messages.
  - 13:05 - Service outage occurs.
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
  - In particular, AppArmor v4.0.0 rules without a (currently prerelease?) `runc` fix from https://github.com/containerd/containerd/pull/10123

- Although the approximate root cause was that error messages during operational processes were ignored, the deeper reason for that seems to be a lax, somewhat hurried, and overconfident attitude during deployment of upgrades.  In particular, a mixture of "we can investigate that later", "it's working again, so we can take a break", and "it's a problem due to some other component, it'll probably fix itself" combined with an element of "we don't want to spend time investigating what we think is someone else's problem" contributed to the lack of investigation.

## What went well?

- During recovery, the deployment-time container teardown problem was solved (albeit at some risk; outage recovery isn't a great time to upgrade dependencies).
- The outage highlighted an unresolved problem in our container deployment process.

## Prevention Measures

**Storage Configuration**

The recommended action here is to leave the storage configuration as it is configured today.  If any form of logging occurs in production to the extent that it can exhaust a filesystem completely, then it is helpful for that to become known to the team at an early stage and for it to be a priority to resolve.

**Alerting**

We discontinued automated alerting for the service in May of Y2021, and the team has expressed a preference not to use automated alerting.

The recommended action here is to remind the team to regularly check the status of the site when they feel comfortable to; we will not add automated alerting at this time.

**Operational Processes**

The team has expressed that an aligment of personal incentives with operational process quality is the best way to achieve long-term improvements.

The recommended action here is that the team should be reminded that they can spend as much time as they like to investigate production warning and error messages.

**Upgrade Processes**

The team suggests that there is a tension between performing careful, gradual upgrades in a development environment, and the difficulty and elapsed-time cost of creating suitable environments that accurately replicate enough of the production environment.

There is no recommended action item here yet; the team feels that there is value in allowing some unexpected and unanticipated variance as a result of manual deployments, since this can assist with the discovery and exploration of problems that may be worth reporting and/or documenting.
