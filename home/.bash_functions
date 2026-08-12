# ~/.bash_functions - generic helper functions
#
# Employer- or project-specific functions belong in ~/.bash_work, which is
# untracked and sourced last by ~/.bashrc. Because it is sourced last, it can
# also override any function defined here (see gtp and asl below).

##### Git helpers #####

# Checkout a branch
gtc() {
  git checkout "$1"
}

# Commit and push. With a message, commits it directly; without one, opens an
# editor and then reapplies a stash (used to finish a merge started by gtm).
#
# ~/.bash_work may override this to add repo-specific pre-commit hooks.
gtp() {
  if [ -n "$1" ]; then
    git add -A
    git commit -m "$1"
    git push
  else
    git add -A
    git commit
    git push
    git stash apply
  fi
}

# Create a new branch, commit everything on it, and push with upstream tracking
gtn() {
  git checkout -b "$1"
  git add -A
  git commit
  git push -u origin "$1"
}

# Merge the given branch into the current feature branch, stashing first
gtm() {
  export FEAT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  git stash save -u
  git checkout "$1"
  git pull

  git checkout $FEAT_BRANCH
  git merge "$1"
}

##### AWS #####

# SSO login and export the profile.
# ~/.bash_work may override this to add per-project default regions.
asl() {
  aws sso login --profile "$1"
  export AWS_PROFILE="$1"
}

##### OpenVPN #####

# Disconnect every active openvpn3 session
ovd() {
  openvpn3 sessions-list |
    sed -n 's/^[[:space:]]*Path:[[:space:]]*//p' |
    while read -r session_path; do
      [ -n "$session_path" ] || continue
      openvpn3 session-manage --path "$session_path" --disconnect
    done
}

##### Project / file helpers #####

# Scaffold a Lambda handler with its test files
mklambda() {
  mkdir -p "$1/__tests__"
  touch "$1/v1-$1.ts"
  touch "$1/__tests__/v1-$1.test.ts"
  touch "$1/__tests__/v1-$1.integration.test.js"
}

# bc calculator, two decimal places
c() {
  echo "scale=2;$1" | bc
}

# mkdir -p + touch, in one step
mkfile() {
  if [ -z "$1" ]; then
    echo "Usage: mkfile <path/to/file>"
    return 1
  fi

  local dirpath
  dirpath=$(dirname "$1")
  mkdir -p "$dirpath" && touch "$1"
}

##### Media #####

# Record the screen with audio to <name>.mp4
capture() {
  ffmpeg -f x11grab -s 1920x1080 -i :0.0 -f alsa -i default \
    -c:v libx264 -preset veryfast -crf 23 -c:a aac -pix_fmt yuv420p "$1.mp4"
}
