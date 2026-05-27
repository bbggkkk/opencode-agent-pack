#!/bin/sh
set -eu

scripts/validate-agent-frontmatter.sh
scripts/validate-production-artifacts.sh
scripts/validate-production-invariants.sh
scripts/test-verification-manifest-negative.sh
scripts/test-production-artifacts-negative.sh
scripts/smoke-install.sh

printf 'all validations ok\n'
