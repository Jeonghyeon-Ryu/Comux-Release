#!/bin/sh
#
# Comux TUI installer — terminal-only build for Linux servers and SSH boxes.
#
#   curl -fsSL https://jeonghyeon-ryu.github.io/Comux-Release/install.sh | sh
#
# No root required. Node.js is NOT required — the bundle embeds its own runtime.
#
# Environment overrides:
#   COMUX_VERSION       install a specific version (e.g. 1.1.0) instead of latest
#   COMUX_INSTALL_DIR   default: ~/.local/share/comux
#   COMUX_BIN_DIR       default: ~/.local/bin
#
set -eu

REPO=Jeonghyeon-Ryu/Comux-Release
INSTALL_DIR=${COMUX_INSTALL_DIR:-$HOME/.local/share/comux}
BIN_DIR=${COMUX_BIN_DIR:-$HOME/.local/bin}

if [ -t 1 ]; then B=$(printf '\033[1m'); D=$(printf '\033[2m'); R=$(printf '\033[0m')
else B=; D=; R=; fi
say()  { printf '%s\n' "$*"; }
step() { printf '%s==>%s %s\n' "$B" "$R" "$*"; }
die()  { printf '%serror:%s %s\n' "$(printf '\033[31m')" "$R" "$*" >&2; exit 1; }

# --- preflight ----------------------------------------------------------------
[ "$(uname -s)" = Linux ] || die "this installer is for Linux. macOS/Windows: see https://jeonghyeon-ryu.github.io/Comux-Release/"
case "$(uname -m)" in
  x86_64|amd64) ARCH=x64 ;;
  *) die "unsupported architecture: $(uname -m) (only x86_64 is published today)" ;;
esac

if command -v curl >/dev/null 2>&1; then   fetch() { curl -fsSL "$1"; }; download() { curl -fL# -o "$2" "$1"; }
elif command -v wget >/dev/null 2>&1; then fetch() { wget -qO- "$1"; };  download() { wget -q --show-progress -O "$2" "$1"; }
else die "need curl or wget"; fi
command -v tar >/dev/null 2>&1 || die "need tar"

# --- resolve the release ------------------------------------------------------
# GitHub returns pretty-printed JSON, so an asset's fields follow its "name" line
# and a windowed grep is enough to pair them up without a JSON parser.
field_after_name() { # <json> <asset-name> <field-regex>
  printf '%s\n' "$1" | grep -A40 "\"name\": *\"$2\"" \
    | sed -n "s/.*\"$3\".*/\1/p" | head -1
}
asset_url()    { field_after_name "$1" "$2" 'browser_download_url": *"\([^"]*\)'; }
asset_sha256() { field_after_name "$1" "$2" 'digest": *"sha256:\([0-9a-f]\{64\}\)'; }

if [ -n "${COMUX_VERSION:-}" ]; then
  TAG="v${COMUX_VERSION#v}"
  step "installing comux $TAG"
  API_JSON=$(fetch "https://api.github.com/repos/$REPO/releases/tags/$TAG") \
    || die "no release tagged $TAG"
  TARBALL="comux-tui-${TAG#v}-linux-$ARCH.tar.gz"
else
  step "resolving the latest release"
  API_JSON=$(fetch "https://api.github.com/repos/$REPO/releases/latest") \
    || die "could not reach the GitHub API"
  TAG=$(printf '%s\n' "$API_JSON" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)
  TARBALL="comux-tui-${TAG#v}-linux-$ARCH.tar.gz"

  # A Windows-only release would be "latest" without carrying a TUI build, so
  # fall back to the newest release that actually has one (the list is ordered
  # newest first).
  if ! printf '%s\n' "$API_JSON" | grep -q "\"name\": *\"$TARBALL\""; then
    API_JSON=$(fetch "https://api.github.com/repos/$REPO/releases?per_page=30") \
      || die "could not reach the GitHub API"
    TARBALL=$(printf '%s\n' "$API_JSON" \
      | sed -n "s/.*\"name\": *\"\(comux-tui-[0-9][^\"]*-linux-$ARCH\.tar\.gz\)\".*/\1/p" | head -1)
    [ -n "$TARBALL" ] || die "no published comux-tui build for linux-$ARCH"
  fi
fi

VERSION=$(printf '%s' "$TARBALL" | sed -n "s/^comux-tui-\(.*\)-linux-$ARCH\.tar\.gz$/\1/p")
[ -n "$VERSION" ] || die "could not determine the version to install"

URL=$(asset_url    "$API_JSON" "$TARBALL")
SHA=$(asset_sha256 "$API_JSON" "$TARBALL")
[ -n "$URL" ] || URL="https://github.com/$REPO/releases/download/v$VERSION/$TARBALL"

# --- download -----------------------------------------------------------------
TMP=$(mktemp -d "${TMPDIR:-/tmp}/comux-install.XXXXXX")
trap 'rm -rf "$TMP"' EXIT INT TERM

step "downloading comux $VERSION ${D}($TARBALL, ~50 MB)${R}"
download "$URL" "$TMP/$TARBALL" || die "download failed: $URL"

if [ -n "$SHA" ]; then
  if   command -v sha256sum >/dev/null 2>&1; then GOT=$(sha256sum "$TMP/$TARBALL" | cut -d' ' -f1)
  elif command -v shasum    >/dev/null 2>&1; then GOT=$(shasum -a 256 "$TMP/$TARBALL" | cut -d' ' -f1)
  else GOT=; fi
  if [ -n "$GOT" ]; then
    [ "$GOT" = "$SHA" ] || die "checksum mismatch — expected $SHA, got $GOT"
    step "checksum verified ${D}(sha256)${R}"
  fi
fi

# --- install ------------------------------------------------------------------
step "unpacking into $INSTALL_DIR"
tar -xzf "$TMP/$TARBALL" -C "$TMP" || die "could not unpack the archive"
SRC="$TMP/comux-linux-$ARCH"
[ -d "$SRC" ] || SRC=$(find "$TMP" -maxdepth 1 -type d -name 'comux-*' | head -1)
[ -d "$SRC" ] || die "unexpected archive layout"

mkdir -p "$(dirname "$INSTALL_DIR")" "$BIN_DIR"
rm -rf "$INSTALL_DIR.old"
[ -d "$INSTALL_DIR" ] && mv "$INSTALL_DIR" "$INSTALL_DIR.old"
mv "$SRC" "$INSTALL_DIR"
rm -rf "$INSTALL_DIR.old"
chmod +x "$INSTALL_DIR/comux" "$INSTALL_DIR/comuxd" "$INSTALL_DIR/run.sh" 2>/dev/null || true

# Wrappers, not symlinks: the bundle's launchers locate themselves with
# dirname "$0", which a symlink in ~/.local/bin would resolve to the wrong tree.
# Bare `comux` starts the daemon and attaches (like tmux); `comux <cmd>` is the CLI.
cat > "$BIN_DIR/comux" <<EOF
#!/bin/sh
[ \$# -eq 0 ] && exec "$INSTALL_DIR/run.sh"
exec "$INSTALL_DIR/comux" "\$@"
EOF
cat > "$BIN_DIR/comuxd" <<EOF
#!/bin/sh
exec "$INSTALL_DIR/comuxd" "\$@"
EOF
chmod +x "$BIN_DIR/comux" "$BIN_DIR/comuxd"

# --- done ---------------------------------------------------------------------
say ""
say "${B}comux $VERSION installed${R}  ${D}$INSTALL_DIR${R}"
say ""
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    say "  ${B}$BIN_DIR is not on your PATH.${R} Add it:"
    say "    ${D}echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.profile && . ~/.profile${R}"
    say "" ;;
esac
say "  ${B}comux${R}          start the daemon and attach"
say "  ${D}Ctrl+B q${R}       detach — your shells keep running"
say "  ${D}Ctrl+B ?${R}       keyboard shortcuts"
say "  ${B}comux ls${R}       list terminals from any shell"
say ""
