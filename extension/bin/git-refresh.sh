#!/bin/sh

git standing &&
    git fetch upstream "${UPSTREAM_BRANCH}" &&
    THIS_COMMIT=$(git rev-parse HEAD) &&
    MASTER_COMMIT=$(git rev-parse "upstream/${UPSTREAM_BRANCH}") &&
    BASE_COMMIT=$(git merge-base ${THIS_COMMIT} ${MASTER_COMMIT}) &&
    git checkout -b scratch_$(uuidgen) &&
    if git rebase "upstream/${UPSTREAM_BRANCH}"
    then
        git commit --allow-empty --message "Sucessfully rebased upstream/${UPSTREAM_BRANCH}: THIS_COMMIT=${THIS_COMMIT}, MASTER_COMMIT=${MASTER_COMMIT}, BASE_COMMIT=${BASE_COMMIT}"
    else
        echo Failed to rebase upstream/${UPSTREAM_BRANCH}: THIS_COMMIT=${THIS_COMMIT}, MASTER_COMMIT=${MASTER_COMMIT}, BASE_COMMIT=${BASE_COMMIT} &&
            cat .git/rebase-merge/message
    fi