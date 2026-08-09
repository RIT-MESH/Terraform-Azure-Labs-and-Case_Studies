# 15 — Activity log alert + action group webhook (advanced)

Lab 02 made a **metric** alert (numbers over time). Activity-log alerts fire on **control-
plane events** — e.g. "someone deleted a resource group". This lab creates an action group
with a **webhook** receiver and an activity log alert that triggers when a resource group
is deleted in the subscription.

> Set `webhook_url` to your own endpoint (a Slack/Teams incoming webhook, or a
> requestbin for testing).
