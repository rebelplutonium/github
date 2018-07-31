#!/bin/sh

git add . &&
    if git diff-index --quiet HEAD --
    then
        echo SKIPPING &&
            git rebase --skip
    else
        echo CONTINUING &&
            git rebase --continue
    fi