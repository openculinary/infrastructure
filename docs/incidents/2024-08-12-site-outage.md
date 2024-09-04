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

- Although the approximate root cause was that error messages during operational processes were ignored, the deeper reason for that seems to be a lax, somewhat hurried, and overconfident attitude during deployment of upgrades.  In particular, a mixture of "we can investigate that later", "it's working again, so we can take a break", and "it's a problem due to some other component, it'll probably fix itself" combined with an element of "we don't want to spend time investigating what we think is someone else's problem" contributed to the lack of investigation.

## What went well?

- During recovery, the deployment-time container teardown problem was solved (albeit at some risk; outage recovery isn't a great time to upgrade dependencies).

## Prevention Measures

**Storage Configuration**

**Alerting**

We discontinued automated alerting for the service in May of Y2021, and generally the team has expressed a preference not to use automated alerting due to the potential for it to intrusively disrupt everyday life without much of a sense of opt-in (in other words: it's OK to manually check the status of the service, and to investigate if it seems unavailable, but to receive pings that have an attached or socially implied expectation of urgency can be stressful to manage).

The recommended action here is to remind the team to regularly check the status of the site when they feel comfortable to; we will not add automated alerting at this time.

**Operational Processes**

Adding pressure to the team is unlikely to improve the quality of operations in the long-term.  In the short-term, we might encounter some expected benefits (reduction in production error metrics, ...), but enforcement of rules by means of pressure or threat tends to wear out the team -- and experience and knowledge are important to retain quality (while also bearing in mind that we should keep systems as simple as possible, to allow newcomers to gain the same level of experience).

With that in mind, recommendations to improve operational processes should focus on the team's intrinsic motivations, and in particular to collect feedback about what those are and why it's important to be thoughtful and careful during upgrades.

The team suggests that there is a tension between performing careful, gradual upgrades in a development environment, and the difficulty and elapsed-time cost of creating suitable environments that accurately replicate enough of the production environment.

[ to be continued ]

**Upgrade Processes**
