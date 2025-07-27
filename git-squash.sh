#!/bin/sh

# This script helps with rebasing and squashing, when your GIT provider does not
# provide with the 'Squash Merge' in the Merge requests. It takes the first commit
# and then squashes all the other ones. It will have to force push, so that the
# updated branch is only one commit.

# chmod a+x git-squash
# Usage: git-squash.sh <base_branch> <target_branch>
# For example: git-squash.sh main feature/TCK-123-Awesome-feature

# Parameters
BASE_BRANCH=$1
TARGET_BRANCH=$2

if [ -z "$BASE_BRANCH" ] || [ -z "$TARGET_BRANCH" ]; then
  echo "Usage: $0 <base_branch> <target_branch>"
  exit 1
fi

# Checkout the target branch
git checkout "$TARGET_BRANCH" || { echo "Failed to checkout $TARGET_BRANCH"; exit 1; }

# Ensure the base branch exists locally
git fetch origin "$BASE_BRANCH" || { echo "Failed to fetch $BASE_BRANCH"; exit 1; }

# Find the first commit of the target branch compared to the base branch
FIRST_COMMIT=$(git log --reverse --pretty=format:"%H" "$BASE_BRANCH..$TARGET_BRANCH" | head -n 1)
COMMIT_MESSAGE=$(git log --format=%s -n 1 "$FIRST_COMMIT")

if [ -z "$FIRST_COMMIT" ]; then
  echo "No commits to squash. Are the branches correct?"
  exit 1
fi

# Find the merge base between the base branch and the target branch
MERGE_BASE=$(git merge-base "$BASE_BRANCH" "$TARGET_BRANCH")

# Reset to squash all commits
git reset --soft "$MERGE_BASE"

# Commit the squashed changes with the first commit message
git commit --message="$COMMIT_MESSAGE" --no-edit

# Force push the squashed branch
git push --force-with-lease origin "$TARGET_BRANCH"

echo "Branch $TARGET_BRANCH has been squashed and pushed successfully."

## In case of conflicts, resolve them, then run these commands:
# $ git status
# $ git add .
# $ git commit --message="$COMMIT_MESSAGE" --no-edit
# $ git push --force-with-lease origin "$TARGET_BRANCH"
