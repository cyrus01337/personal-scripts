#!/usr/bin/env bash
if ! which gh &> /dev/null; then
    echo "Must have Github CLI (gh) installed to run this script"

    exit 127
elif ! which xargs &> /dev/null; then
    echo "Must have xargs installed to run this script"

    exit 123
fi

github_user="${$GITHUB_USER:-$USER}"
projects_directory="${github_user}-projects"

mkdir -q $projects_directory
cd $projects_directory

if which parallel &> /dev/null; && which nproc &> /dev/null; then
    gh api users/$github_user/repos --paginate --jq ".[].name" | sort | parallel -j$(nproc) xargs -n 1 gh repo clone
else
    gh api users/$github_user/repos --paginate --jq ".[].name" | sort | xargs -n 1 gh repo clone
fi
