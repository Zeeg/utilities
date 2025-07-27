#!/bin/sh

# This script allows you to easily merge the uat/staging/develop branch into your
# current working branch, to keep your branches updated. In addition, you can define
# which are the 'hotfix' branches, and they will be rebased from 'master'/'main'

# Usage
# chmod a+x git-rebase.sh
#
# git-rebase.sh feature/TCK-123-Awesome-feature
# (will merge your develop/staging branch into it)
#
# git-rebase.sh hotfix/urgent-for-production
# (will rebase that branch from the main one)

# Check if a branch name is provided
if [ -z "$1" ]; then
  echo "Error: No branch name provided."
  echo "Usage: $0 <branch-name>"
  exit 1
fi

BRANCH_NAME="$1"
BRANCH_MAIN="main"
BRANCH_DEV="staging"
HOTFIX_REGEX="hotfix/*"

# Fetch all branches
git fetch --all

# shellcheck disable=SC2053
if [ "$BRANCH_NAME" = "$HOTFIX_REGEX" ]; then
  # Workflow for hotfix branches
  echo "Processing hotfix branch: $BRANCH_NAME"
  git checkout "$BRANCH_MAIN"
  git pull origin "$BRANCH_MAIN"
  git checkout "$BRANCH_NAME"
  git pull origin "$BRANCH_NAME"
  git rebase -i "$BRANCH_MAIN"
  git push origin "$BRANCH_NAME" --force
else
  # Workflow for other branches
  echo "Processing feature or other branch: $BRANCH_NAME"
  git checkout "$BRANCH_DEV"
  git pull origin "$BRANCH_DEV"
  git checkout "$BRANCH_NAME"
  git pull origin "$BRANCH_NAME"
  git merge --no-edit "$BRANCH_DEV"
  git push origin "$BRANCH_NAME"
fi
