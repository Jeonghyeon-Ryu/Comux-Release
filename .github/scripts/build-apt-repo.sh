#!/usr/bin/env bash
#
# Rebuild the signed APT repository served from GitHub Pages (docs/apt/).
#
#   build-apt-repo.sh <path-to.deb> [repo-root]
#
# Only the newest package is kept: pool/ and dists/ are wiped and regenerated
# on every run, so the git tree never accumulates old 80MB Electron builds.
#
# Signing key is taken from the ambient gpg keyring. Required env:
#   APT_GPG_KEY_ID       fingerprint or key id of the signing key
#   APT_GPG_PASSPHRASE   passphrase for that key (optional; empty = no passphrase)
#
# Requires: dpkg-dev (dpkg-scanpackages), apt-utils (apt-ftparchive), gnupg, gzip.
set -euo pipefail

DEB="${1:?usage: build-apt-repo.sh <path-to.deb> [repo-root]}"
ROOT="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

SUITE=stable
COMPONENT=main
ARCH=amd64
APT="$ROOT/docs/apt"
DIST="$APT/dists/$SUITE"
BINDIR="$DIST/$COMPONENT/binary-$ARCH"

for tool in dpkg-deb dpkg-scanpackages apt-ftparchive gpg gzip; do
  command -v "$tool" >/dev/null 2>&1 || { echo "missing tool: $tool" >&2; exit 1; }
done
[ -f "$DEB" ] || { echo "no such deb: $DEB" >&2; exit 1; }
: "${APT_GPG_KEY_ID:?APT_GPG_KEY_ID must be set}"

PKG=$(dpkg-deb -f "$DEB" Package)
VER=$(dpkg-deb -f "$DEB" Version)
POOL="pool/$COMPONENT/${PKG:0:1}/$PKG"
echo "==> $PKG $VER ($ARCH)"

# --- rebuild the tree from scratch (latest-only) ------------------------------
rm -rf "$APT/pool" "$APT/dists"
mkdir -p "$APT/$POOL" "$BINDIR"
cp "$DEB" "$APT/$POOL/${PKG}_${VER}_${ARCH}.deb"

cd "$APT"
dpkg-scanpackages --arch "$ARCH" pool 2>/dev/null > "$BINDIR/Packages"
gzip -9cn "$BINDIR/Packages" > "$BINDIR/Packages.gz"
echo "==> Packages: $(grep -c '^Package:' "$BINDIR/Packages") entry"

apt-ftparchive \
  -o "APT::FTPArchive::Release::Origin=Comux" \
  -o "APT::FTPArchive::Release::Label=Comux" \
  -o "APT::FTPArchive::Release::Suite=$SUITE" \
  -o "APT::FTPArchive::Release::Codename=$SUITE" \
  -o "APT::FTPArchive::Release::Architectures=$ARCH" \
  -o "APT::FTPArchive::Release::Components=$COMPONENT" \
  -o "APT::FTPArchive::Release::Description=Comux — terminal multiplexer for AI agents" \
  release "dists/$SUITE" > "$DIST/Release"

# --- sign ---------------------------------------------------------------------
gpgsign() {
  gpg --batch --yes --pinentry-mode loopback \
      ${APT_GPG_PASSPHRASE:+--passphrase "$APT_GPG_PASSPHRASE"} \
      --local-user "$APT_GPG_KEY_ID" "$@"
}
gpgsign --clearsign            -o "$DIST/InRelease"   "$DIST/Release"
gpgsign --detach-sign --armor  -o "$DIST/Release.gpg" "$DIST/Release"

# Keep the published public key in lockstep with whatever key just signed.
gpg --armor --export "$APT_GPG_KEY_ID" > "$APT/comux.asc"
gpg --export         "$APT_GPG_KEY_ID" > "$APT/comux.gpg"

# --- self-check ---------------------------------------------------------------
gpg --verify "$DIST/InRelease"   >/dev/null 2>&1 || { echo "InRelease failed to verify" >&2; exit 1; }
gpg --verify "$DIST/Release.gpg" "$DIST/Release" >/dev/null 2>&1 \
  || { echo "Release.gpg failed to verify" >&2; exit 1; }

echo "==> signed by $APT_GPG_KEY_ID"
find "$APT" -type f -printf '    %-58p %8s\n' | sed "s#$APT/##"
