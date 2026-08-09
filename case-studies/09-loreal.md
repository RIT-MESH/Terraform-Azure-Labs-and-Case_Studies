# Case Study 09 — L'Oréal

**Organization:** L'Oréal · **Industry:** Consumer goods / beauty · **Scale:** Global consumer brands and e-commerce

## The challenge
Serve global consumer web properties with good performance and regional failover, while
keeping a single deployment pipeline.

## The Terraform-on-Azure approach
- **Traffic Manager** routing users to the closest healthy regional web-app stamp.
- **App Service** with deployment slots for safe, swap-based releases.
- Terraform parameterized per region; one codebase, many tfvars.
- Central logging and tags for cost attribution by brand/region.

## Reported outcomes (qualitative)
- Better global performance and failover.
- Safe, slot-based deployments.
- Clear per-brand cost visibility via tags.

## Labs to run
- `labs/section-04-modules-and-networking/09-traffic-manager` and `10`.
- `labs/section-03-web-apps-and-databases/05-deployment-slots-create` and `06`.
- `labs/section-03-web-apps-and-databases/04-resource-tags`.

## Source / verify
Verify at Microsoft Customer Stories (https://www.microsoft.com/en-us/customerstories — search "L'Oreal Azure").
