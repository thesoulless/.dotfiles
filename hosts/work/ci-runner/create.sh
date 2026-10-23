#!/usr/bin/env bash
# Build the runner image and create the `ci-runner` container, registered
# with the org. Run once, and again after editing the image (the old
# container's state, e.g. toolchains and caches, is lost). hosts/work.nix
# boots the container at login from then on.
#
#   create.sh <org> <registration-token> [label]
#
# The token comes from the org's Settings > Actions > Runners > New self-hosted
# runner and lives an hour; it stays visible in `container inspect` until the
# container is recreated. The label is what the repository variable
# CI_HEAVY_RUNNER is set to.
set -eu

org=${1:?org}
token=${2:?registration token}
label=${3:-mac-m5}
dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

container build -t local/ci-runner:latest "$dir"
if container inspect ci-runner >/dev/null 2>&1; then
	container delete --force ci-runner
fi
# One VM for cargo, Postgres, Redis and BuildKit together; 10 GB is what a
# 24 GB laptop can spare, and the guest never hands memory back to macOS.
# ALL capabilities and no masked or read-only /proc and /sys paths are what
# dockerd needs; the VM is the isolation boundary.
container run --detach --init --name ci-runner --cpus 8 --memory 10g \
	--cap-add ALL --read-only-path NONE --masked-path NONE \
	--env RUNNER_URL="https://github.com/$org" \
	--env RUNNER_TOKEN="$token" \
	--env RUNNER_NAME="$(scutil --get ComputerName)" \
	--env RUNNER_LABELS="$label" \
	local/ci-runner:latest
