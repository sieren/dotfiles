#!/bin/bash
# A collection of random git functions which help out during my daily workflow.
# This is kind of an expanded version of git aliases, with some other helper
# functions as well. To install, source this script from your ~/.bashrc file.
#
# All pull requests welcome. For more info, contact me at GitHub:
# http://github.com/nikreiman

# Prefer git in /usr/local to the system default. This is particularly useful on
# macOS, where Xcode ships an older version of git than homebrew.
[ -e "/usr/local/bin/git" ] && alias git="/usr/local/bin/git"

# Delimiter to be used when creating branches. By default, this is
# $GIT_BRANCH_DELIMITER, which lends itself nicely to the git branch grouping
# quasi-feature. That means branches will look like
# "username/upstream-branch/feature-name".
#
# Sometimes $GIT_BRANCH_DELIMITER can be problematic, such as in the case of one
# particular project I work on where a jenkins server attempts to create files
# on a scratch directory for each branch that it builds, and of course
# $GIT_BRANCH_DELIMITER in the filename causes this to fail spectacularly. To
# change the delimiter, export this variable elsewhere.
if [ -z "$GIT_BRANCH_DELIMITER" ]; then
  GIT_BRANCH_DELIMITER="/"
fi

######################
# Git shell launcher #
######################

function git-shell-with-title() {
  local title=$(basename $(pwd))
  case $(uname) in
    Darwin)
      if [ "$TERM_PROGRAM" = "iTerm.app" ] ; then
        echo -e "\033]0;$title\a"
      fi
      exec git sh
      ;;
    Linux)
      echo -en "\033]0;$title\a"
      exec git sh
      ;;
    MINGW*)
      if [[ $TERM == xterm* ]]; then
        echo -e "\033]0;$title\a"
      fi
      exec "$SCRIPTS/git-sh-win.bash"
      ;;
    *)
      exec git sh
      ;;
  esac
}

##########
# Branch #
##########

# This function must be defined rather early, other functions call it
function git-branch-current() {
  git rev-parse --abbrev-ref HEAD
}

function git-branch-base() {
  local baseBranch=$(git-branch-current)
  if [ $(echo "$baseBranch" | grep "$GIT_BRANCH_DELIMITER") ]; then
    baseBranch=$(echo $baseBranch | cut -d $GIT_BRANCH_DELIMITER -f 2)
  fi
  printf "%s" $baseBranch
}

function git-branch-create() {
  local baseBranch=$(git-branch-base)
  if [ "$baseBranch" = "HEAD" ]; then
    echo "It seems that you are in detached HEAD, please checkout a branch"
    return 1
  fi
  local featureName=$1
  local newBranchName=$(printf "%s%s%s%s%s" "$USER" "$GIT_BRANCH_DELIMITER" "$baseBranch" "$GIT_BRANCH_DELIMITER" "$featureName")
  local reply="n"
  read -p "Create branch $newBranchName ? " reply
  if [ "$reply" = "y" ]; then
    git checkout -b $newBranchName
  fi
}

function git-branch-cleanup() {
  local currentBranch=$(git-branch-current)
  local otherBranch=
  local logOutput=
  for otherBranch in $(git branch | grep "${USER}${GIT_BRANCH_DELIMITER}${currentBranch}"); do
    logOutput=$(git log $otherBranch ^$currentBranch)
    if [ -z "$logOutput" ]; then
      git branch -d $otherBranch
    fi
  done
}

function git-branch-cleanup-remote() {
  if [ $GIT_BRANCH_DELIMITER != "/" ]; then
    echo "TODO: Function not supported for custom branch delimiters"
    return
  fi

  local otherBranch=
  local localBranchName=
  local originName="origin"
  echo "Fetching..."
  git fetch
  echo "Pruning..."
  git remote -v prune $originName
  for otherBranch in $(git branch -a | grep "remotes/${originName}/${USER}"); do
    localBranchName=$(printf "%s" ${otherBranch} | cut -d / -f 3-)
    echo $localBranchName
    if [ -z "$(git branch | grep "$localBranchName")" ]; then
      local reply='n'
      read -p "Delete remote branch '$localBranchName'? " reply
      if [ "$reply" = "y" ]; then
        git push origin :${localBranchName}
      fi
    fi
  done
}

function git-branch-bind() {
  local currentBranch=$(git-branch-current)
  git branch --set-upstream-to=origin/$currentBranch $currentBranch
}

function git-branch-diff() {
  local baseBranch=$(git-branch-base)
  local currentBranch=$(git-branch-current)
  git log $* $currentBranch ^origin/$baseBranch
}

function git-branch-rebase() {
  local baseBranch=$(git-branch-base)
  local currentBranch=$(git-branch-current)
  git fetch && git rebase origin/$baseBranch
}

#######
# Log #
#######

gitLogFormatShort="%C(cyan)%cr %Creset%s"
gitLogFormatOneline="%C(yellow)%h %C(green)%an %C(cyan)%cr %Creset%s"

function git-log-last-pushed-hash() {
  local currentBranch=$(git-branch-current)
  git log --format="%h" -n 1 origin/${currentBranch}
}

function git-log-for-branch() {
  branch="$1"
  git --no-pager log --format="$gitLogFormatShort" --no-merges $branch --not \
    $(git for-each-ref --format="%(refname)" refs/remotes/origin | \
      grep -F -v $branch)
}

function git-log-incoming() {
  local branch=$(git-branch-current)
  git --no-pager log --format="$gitLogFormatOneline" $* origin/$branch ^$branch
}

function git-log-outgoing() {
  local branch=$(git-branch-current)
  git --no-pager log --format="$gitLogFormatOneline" $* $branch ^origin/$branch
}

function git-log-incoming-interactive() {
  local branch=$(git-branch-current)
  local response=
  for i in $(git --no-pager log --format="%h" origin/$branch ^$branch) ; do
    clear
    git show $i
    read -p "Press any key to continue " response
  done
}

function git-log-last-hash() {
  git log -n 1 --format="%h"
}

function git-log-detail() {
  git --no-pager log --full-diff -p $@
}

function git-log-detail-commit() {
  if [ -z "$1" ] ; then
    commit=$(git-log-last-hash)
  else
    commit=$1
  fi

  git --no-pager log -n 1 --full-diff -p $commit
}

function git-log-since-last-tag() {
  local format=$gitLogFormatShort
  if [ "$1" = "changelog" ] ; then
    format="- %s"
  fi
  local lastTag=$(git-tag-last)
  printf "Changes since version %s:\n" $lastTag
  git --no-pager log --format="$format" "${lastTag}..HEAD"
}

function git-changelog-since-last-tag() {
  git-log-since-last-tag changelog
}

##########
# Rebase #
##########

function git-rebase-branch() {
  local currentBranch=$(git-branch-current)
  local baseBranch=$(git-branch-base)
  if [ "$1" ]; then
    baseBranch=$1
  else
    baseBranch=$(printf "origin/%s" $baseBranch)
  fi
  local headCommit=$(git log --format="%h" $currentBranch ^"origin/$baseBranch" | tail -1)
  git rebase -i ${headCommit}^
}

function git-rebase-unpushed() {
  git rebase --interactive $(git-log-last-pushed-hash)
}

########
# Push #
########

function git-push-force() {
  local currentBranch=$(git-branch-current)
  git push --force origin ${currentBranch}
}

############
# Checkout #
############

function git-checkout-remote-branch() {
  local remote="origin"
  local branchName="$1"
  if [ "$2" ]; then
    remote=$2
  fi
  # Check if the branch begins with a remote origin (from tab-completion)
  if [[ $branchName == $remote* ]]; then
    branchName=$(printf "%s" $branchName | cut -d / -f 2-)
  fi
  git checkout --track -b $branchName $remote/$branchName
  git branch --set-upstream-to=$remote/$branchName $branchName
}

#############
# Submodule #
#############

function git-submodule-peek() {
  local submodule="$1"
  if ! [ -e "$submodule" ]; then
    echo "'$submodule' is not a valid submodule path"
    return
  fi
  shift

  local hashes=$(git log --patch --max-count=1 --format=fuller --no-merges "$submodule" | tail -2)
  local oldHash=$(echo "$hashes" | head -1 | cut -d ' ' -f 3)
  local newHash=$(echo "$hashes" | tail -1 | cut -d ' ' -f 3)
  (cd "$submodule"
    git log $* ${oldHash}..${newHash}
  )
}

#######
# Tag #
#######

function git-tag-changelog() {
  local tagName=
  if ! [ -z "$1" ] ; then
    tagName=$1
  else
    tagName=$(git-tag-last)
  fi

  git tag -v $tagName | tail -n +6
}

function git-tag-for-commit() {
  git name-rev --name-only $1
}

function git-tag-last() {
  printf "%s\n" $(git-tag-list-sorted | tail -1)
}

# When git prints out tags with -l, they are sorted by not correctly when you
# have versions like 1.0.10, which would come before 1.0.2.
function git-tag-list-sorted() {
  git tag -l | sort -k 1n,1 -k 2n,2 -k 3n,3 -t '.'
}

function git-tag-next-version() {
  local lastTag=$(git-tag-last)
  local nextTag="${lastTag%.*}.$((${lastTag##*.} + 1))"

  if ! [ -z "$1" ] ; then
    local versionFile=$1
    if [ -z "$(grep $nextTag $versionFile)" ] ; then
      echo "You forgot to set the current version in $versionFile!"
      return 1
    fi
  fi

  local changelogFile=/tmp/changelog.txt
  git-log-since-last-tag changelog > $changelogFile
  $EDITOR $changelogFile
  echo "Tagging release $nextTag with:"
  cat $changelogFile
  git tag -s $nextTag -F $changelogFile
  if ! [ -z `which pbcopy` ] ; then
    pbcopy < $changelogFile
    echo "Changelog copied to clipboard"
  fi
  rm $changelogFile
}

###############
# Cherry-Pick #
###############

function git-cherry-pick-branch-head() {
  local branchName=$1
  if [ -z "$branchName" ] ; then
    echo "Usage: git-cherry-pick-branch-head <branch>"
    return 1
  fi
  local headCommit=$(git log --oneline --max-count=1 $branchName | cut -d ' ' -f 1)
  git log --format=full --max-count=1 $headCommit
  local answer="n"
  read -p "Cherry-pick to current branch? " answer
  case "$answer" in
    y) git cherry-pick $headCommit ; return $? ;;
    *) echo "Nevermind" && return 1 ;;
  esac
}

# "fake" rebase achieved by checking out the original parent branch
# and then cherry picking the HEAD commit of the current branch on
# top of it.
function git-cherry-pick-rebase() {
  local currentBranch=$(git-branch-current)
  local parentBranch=$(git-branch-base)
  local tmpBranch="${currentBranch}-rebase-tmp"
  local total=6
  local i=1
  local abort=0
  local cmd=

  for cmd in "git checkout $baseBranch" \
    "git checkout -b $tmpBranch" \
    "git-cherry-pick-branch-head $currentBranch" \
    "git branch -D $currentBranch" \
    "git checkout -b $currentBranch" \
    "git branch -D $tmpBranch"; do
    if [ $abort -eq 1 ]; then
      printf "ABORTED: "
    fi
    printf "Step %d/%d: %s\n" $i $total "$cmd"
    i=$(($i + 1))

    if [ $abort -eq 0 ]; then
      eval $cmd
      abort=$?
    fi
  done

  return $abort
}

##########
# Commit #
##########

function git-commit-wip() {
  local commitMessage="Do not merge"
  local currentBranch=$(git-branch-current)
  if [ $(echo $currentBranch | grep $GIT_BRANCH_DELIMITER) ]; then
    local featureName=$(echo $currentBranch | cut -d $GIT_BRANCH_DELIMITER -f 3)
    if [ "$featureName" ]; then
      commitMessage=$(printf "%s" $featureName | sed -e 's/-/ /g')
    fi
  fi
  git commit -m "WIP: $commitMessage"
}

function git-commit-fixup() {
  local baseBranch=$(git-branch-base)
  local currentBranch=$(git-branch-current)
  local options=()
  local reply=
  local i=
  local subject=
  local displayOption=

  for i in $(git log --format="%h" $currentBranch ^origin/$baseBranch); do
    subject=$(git log --format="%s" -1 $i)
    displayOption=$(printf "%s: %s" "$i" "$subject")
    options+=("$displayOption")
  done

  local selectedHash=
  PS3="Squash to which commit? "
  select reply in "${options[@]}"; do break; done
  if [ "$reply" ]; then
    selectedHash=$(printf "%s" "$reply" | cut -d ':' -f 1)
    git commit --fixup $selectedHash
  else
    echo "Invalid selection; aborting"
  fi
}
