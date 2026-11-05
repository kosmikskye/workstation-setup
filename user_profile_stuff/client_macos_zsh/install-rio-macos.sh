
#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/raphamorim/rio.git"
SOURCE_DIR="${RIO_SOURCE_DIR:-$HOME/src/rio}"
APP="/Applications/Rio.app"

log() {
  printf '\n==> %s\n' "$*"
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

# -----------------------------------------
# Dependencies
# -----------------------------------------

[[ "$(uname -s)" == "Darwin" ]] ||
  fail "This script requires macOS."

for cmd in git cargo rustc xcrun codesign ditto; do
  command -v "$cmd" >/dev/null 2>&1 ||
    fail "Missing dependency: $cmd"
done

xcrun --find clang >/dev/null ||
  fail "Install Xcode Command Line Tools: xcode-select --install"

# -----------------------------------------
# Clone / update source
# -----------------------------------------

if [[ -d "$SOURCE_DIR/.git" ]]; then
  log "Updating Rio source"
  git -C "$SOURCE_DIR" pull --ff-only
else
  [[ ! -e "$SOURCE_DIR" ]] ||
    fail "$SOURCE_DIR exists but is not a Git checkout"

  log "Cloning Rio"
  mkdir -p "$(dirname "$SOURCE_DIR")"
  git clone "$REPO" "$SOURCE_DIR"
fi

cd "$SOURCE_DIR"

# -----------------------------------------
# Build with WebGPU support
# -----------------------------------------

log "Building Rio with WebGPU shader support"

cargo build --release -p rioterm --features wgpu --locked

BINARY="$SOURCE_DIR/target/release/rio"
TEMPLATE="$SOURCE_DIR/misc/osx/Rio.app"

[[ -x "$BINARY" ]] ||
  fail "Compiled Rio executable not found"

[[ -d "$TEMPLATE" ]] ||
  fail "macOS app template not found"

# -----------------------------------------
# Create application bundle
# -----------------------------------------

log "Packaging Rio.app"

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

ditto "$TEMPLATE" "$STAGING/Rio.app"

mkdir -p "$STAGING/Rio.app/Contents/MacOS"
cp "$BINARY" "$STAGING/Rio.app/Contents/MacOS/rio"
chmod +x "$STAGING/Rio.app/Contents/MacOS/rio"

# Include bundled terminfo resources if present
if [[ -d "$SOURCE_DIR/misc/72" ]]; then
  mkdir -p "$STAGING/Rio.app/Contents/Resources/72"
  ditto "$SOURCE_DIR/misc/72" \
    "$STAGING/Rio.app/Contents/Resources/72"
fi

# -----------------------------------------
# Sign application
# -----------------------------------------

log "Ad-hoc signing application"

codesign --force --deep --sign - "$STAGING/Rio.app"

codesign --verify --deep --strict "$STAGING/Rio.app" ||
  fail "Code signature verification failed"

# -----------------------------------------
# Install application
# -----------------------------------------

log "Installing into /Applications"

# Avoid replacing a running application
if pgrep -x rio >/dev/null 2>&1; then
  fail "Please quit Rio before installing"
fi

BACKUP=""

if [[ -e "$APP" ]]; then
  BACKUP="/Applications/Rio.backup.$(date +%Y%m%d-%H%M%S).app"
  log "Backing up existing Rio to $BACKUP"
  mv "$APP" "$BACKUP"
fi

if ! ditto "$STAGING/Rio.app" "$APP"; then
  echo "Installation failed" >&2
  rm -rf "$APP"

  if [[ -n "$BACKUP" ]]; then
    mv "$BACKUP" "$APP"
  fi

  exit 1
fi

# -----------------------------------------
# Finished
# -----------------------------------------

log "Rio installed successfully!"

echo "Application: $APP"
echo "WebGPU support: enabled"
echo "Existing Rio backup: ${BACKUP:-none}"
echo
echo "Launch using:"
echo "  open -a Rio"
