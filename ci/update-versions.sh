#!/bin/bash

set -e

clamav_rest_version=$(cat clamav-rest-release/version)
go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1 | awk -F "go" '{print $2}')

pushd source

    source ../pipeline-tasks/setup-commit-signing.sh

    git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
    git remote update
    git fetch --all
    branch_name="dependencies"
    dependencies_branch=$(git branch -r --list | { grep -w "origin/${branch_name}" || test $? = 1; } )
    if [[ -z "$dependencies_branch" ]]; then
        git checkout -b $branch_name
        echo "Created new branch: $branch_name"
    else 
        git checkout $branch_name
        echo "Using existing branch: $branch_name"
    fi
        
    echo "CLAMAV_REST_VERSION=${clamav_rest_version}" > image/args/build-args.conf
    echo "GO_VERSION=${go_version}" >> image/args/build-args.conf

    # Only commit if there are changes
    git_diff=$(git diff image/args/build-args.conf)
    if [[ -z "$git_diff" ]]; then
        echo "No changes to image/args/build-args.conf. Exiting..."
    else 
        git commit -S -m "update depenedencies" image/args/build-args.conf
        git push origin $branch_name

        # Open a PR if one does not exist.
        existing_pr_count=$(gh pr list --author "@cg-ci-bot" --label "dependencies" --json "author" | jq 'length')
        if [[ 0 == "$existing_pr_count" ]]; then
            # be sure the label exists
            gh label create -f dependencies  -c "#e36701" -d "Updates to upstream depenedencies"

            GH_REPO=$(cat .git/config| grep url | head -n 1 | awk -F "url = " '{print $2}')
            
            body=$(cat <<'EOF'
## Changes proposed in this pull request 
- Dependencies updated in image/args/build-args.conf. 

## Security considerations 
Updates are good. 
EOF
)
            base_branch=$(cat .git/branch)

            gh pr create --base ${base_branch} --title "Dependencies updated" --body "${body}" --label "dependencies"
        else
            echo "PR already exists. Exiting..."
        fi
    fi
popd
