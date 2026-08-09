# 10 — Traffic Manager implementation

The same idea as lab 09 but wired through endpoints with explicit priority weights —
useful for a primary/failover pattern. The first endpoint is `priority=1`, the second
`priority=2`. Traffic Manager sends all traffic to priority 1 and fails over to 2.
