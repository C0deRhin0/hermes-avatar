# Failed systemd units cleanup on a stable VPS

Use this when `systemctl --failed` is noisy but the live machine and Hermes gateway are healthy.

## Pattern from this session
- `cloud-init.service` failed from an old first-boot NoCloud seed on `/dev/sr0`
- `systemd-networkd-wait-online.service` failed even though `networkctl status eth0` showed the interface `routable` and `online`
- Hermes gateway was healthy throughout

## Safe investigation order
1. Confirm the failed-unit list:
   - `systemctl --failed --no-pager --plain`
2. Confirm live machine health first:
   - `vps-health`
   - `systemctl is-active hermes-gateway.service`
3. For cloud-init:
   - `cloud-init status --long`
   - inspect `/var/log/cloud-init.log` for `bootcmd` / `ProcessExecutionError`
   - inspect `/var/lib/cloud/instances/*/cloud-config.txt` to see whether the failure came from one-time provisioning logic
4. For wait-online:
   - `networkctl status <iface>`
   - inspect `systemctl cat systemd-networkd-wait-online.service`
   - if needed, run the exact wait command directly to reproduce the timeout

## Decision rule
Only disable or mask when all of the following are true:
- the failure is stale / boot-time, not an active runtime outage
- the host is already healthy and routable now
- Hermes gateway and other important services are active
- the unit provides no useful ongoing signal for this VPS

## Fix used here
### Cloud-init
For a fully provisioned VPS where cloud-init is no longer wanted:
- create `/etc/cloud/cloud-init.disabled`
- disable:
  - `cloud-init-local.service`
  - `cloud-init.service`
  - `cloud-config.service`
  - `cloud-final.service`

### Wait-online
When the network is already healthy in practice but `systemd-networkd-wait-online` keeps timing out and only adds failed-unit noise:
- mask `systemd-networkd-wait-online.service`

### Finish
- run `systemctl reset-failed`
- verify `systemctl --failed` is empty
- verify `hermes-gateway.service` is still active

## Caveats
- Disabling cloud-init is a policy decision: future boots will not run cloud-init unless the disable marker is removed intentionally.
- Masking wait-online means future boots will not block on `network-online.target`; only do this when the VPS posture and service set tolerate it.
- Record the change in the Hermes config changelog when it is durable operator policy.