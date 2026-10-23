#!/bin/bash
# Runs as root under the VM's init (`container run --init`): starts dockerd,
# registers the runner on the first boot, then becomes the runner process.
set -eu

# cgroup v2: move this shell out of the root group and delegate the
# controllers, otherwise dockerd cannot create cgroups (moby's hack/dind).
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
	mkdir -p /sys/fs/cgroup/init
	xargs -rn1 </sys/fs/cgroup/cgroup.procs >/sys/fs/cgroup/init/cgroup.procs || :
	sed -e 's/ / +/g' -e 's/^/+/' </sys/fs/cgroup/cgroup.controllers >/sys/fs/cgroup/cgroup.subtree_control
fi

# /var/run is on the persistent rootfs, so the previous boot's pid files
# survive a restart and dockerd refuses to start over them.
rm -f /var/run/docker.pid /var/run/docker/containerd/containerd.pid

# Docker bridges default to MTU 1500; the VM's uplink is smaller, and large
# packets from service containers would otherwise stall.
mtu=$(cat /sys/class/net/eth0/mtu)
dockerd --group docker --mtu "$mtu" >/var/log/dockerd.log 2>&1 &
for _ in $(seq 60); do
	docker info >/dev/null 2>&1 && break
	sleep 1
done
docker info >/dev/null

# `container run ... local/ci-runner bash`: a shell beside a live dockerd.
[ $# -eq 0 ] || exec "$@"

cd /home/runner
if [ ! -f .runner ]; then
	: "${RUNNER_URL:?https://github.com/<org>}" "${RUNNER_TOKEN:?registration token}"
	labels=()
	[ -n "${RUNNER_LABELS:-}" ] && labels=(--labels "$RUNNER_LABELS")
	runuser -u runner -- ./config.sh --unattended --replace \
		--url "$RUNNER_URL" --token "$RUNNER_TOKEN" \
		--name "${RUNNER_NAME:-$(hostname)}" --work _work "${labels[@]}"
fi
exec runuser -u runner -- ./run.sh
