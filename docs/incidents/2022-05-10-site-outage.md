# Site Outage

## What happened?

13:48 - A cat climbed onto the server and set foot on the power button on top of the case
13:48 - Network services providing the production site were gracefully shutdown
13:48 - The production system halted after graceful shutdown of all system services
13:49 - The power button on the server was pressed again manually (by a human)
13:50 - Network services providing the production site completed startup
13:54 - A manual visit to the production site confirmed that it was operational again

## What went well?

- Unscheduled startup of the site from cold succeeded
- Outage window was minimized thanks to human observation of the hardware at incident-time
- No documentation was required for staff to restore service

## What went wrong?

- Physical Infrastructure: Exposure of server power button led to environmentally-precipitated outage
- Alerting: Staff received no automated notification of production site outage

## Prevention Measures

**Physical Infrastructure**

This was a rare and unpredictable outage, and it's unlikely that the same event will occur again in future.

It is possible to non-destructively remove the signal cable that connects the power button on the server case to the motherboard, and that was considered as a potential prevention measure.

In practice, it's useful to have the power button exposed during maintenance windows and for graceful shutdown.

Recommendation: no follow-up actions.

**Alerting**

This outage was brief in duration and may not have been detected by automated alerting tools.

We were fortunate to have a person on-site at the time who heard the server shutdown (a form of audible alert) and who was able to take the correct remedial action (pressing the power button).

Recommendation: we should review our automated alerting and test it during the next available scheduled maintainence window to confirm that it detects a longer-duration outage of the production site.
