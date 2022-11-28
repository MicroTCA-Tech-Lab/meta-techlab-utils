#!/bin/bash

set -eux

TL=$(repo --show-toplevel)
cd $TL/.repo/manifests

repo manifest -r -o pinned.xml
git add pinned.xml
git commit -m "Create pinned manifest for ${1}"
git tag ${1}

ORIG_BRANCH=$(git rev-parse --abbrev-ref @{upstream} | cut -d/ -f2)
git push origin HEAD:$ORIG_BRANCH
git push --tags
