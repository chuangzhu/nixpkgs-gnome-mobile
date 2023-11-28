#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils common-updater-scripts git

tmpdir="$(mktemp -d)"
git clone --bare --depth=1 --branch=mobile-shell https://gitlab.gnome.org/verdre/mobile-shell.git "$tmpdir"
pushd "$tmpdir"
new_version="unstable-$(git show -s --pretty='format:%cs')"
commit_sha="$(git show -s --pretty='format:%H')"
popd
update-source-version "gnome.gnome-shell" --file=overlay.nix "$new_version" --rev="$commit_sha"

tmpdir="$(mktemp -d)"
git clone --bare --depth=1 --branch=mobile-shell https://gitlab.gnome.org/verdre/mobile-mutter.git "$tmpdir"
pushd "$tmpdir"
new_version="unstable-$(git show -s --pretty='format:%cs')"
commit_sha="$(git show -s --pretty='format:%H')"
popd
update-source-version "gnome.mutter" --file=overlay.nix "$new_version" --rev="$commit_sha"
