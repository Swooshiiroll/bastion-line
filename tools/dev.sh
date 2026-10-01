#!/usr/bin/env bash
# Bastion Line developer commands, the same locally (Git Bash on Windows, any Linux shell) and in CI.
#   tools/dev.sh <command> [args]
#
#   import              import assets (needed once on a fresh checkout, before anything else)
#   check               static checks: draw lint, design data in sync, version consistent
#   test [--only=x]     headless test suite
#   tour                screenshot tour with interaction checks (needs a display)
#   compare             full vs cached tower drawing, pixel by pixel (needs a display)
#   perf [--update]     render the standard scenarios and check tests/perf_budget.json (needs a display)
#   build [windows|linux|all]   export to build/ (Linux also packed as a .tar.gz)
#   version <x.y.z>     set the version in project.godot and both export presets
#   lx                  build Linux and put it on Corundum-LX for playtesting (skipped if LX is off)
#
# Godot: $GODOT, else godot4/godot on PATH, else the WinGet install. Logs go to out/.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p out

find_godot() {
  if [ -n "${GODOT:-}" ]; then echo "$GODOT"; return; fi
  for c in godot4 godot; do command -v "$c" >/dev/null 2>&1 && { command -v "$c"; return; }; done
  local w
  w=$(ls "$HOME"/AppData/Local/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_*/Godot_v4.7*_console.exe 2>/dev/null | head -1)
  [ -n "$w" ] && { echo "$w"; return; }
  echo "dev.sh: Godot 4.7 not found (set GODOT)" >&2; exit 2
}
G=$(find_godot)

# run <name> <timeout s> <godot args...>: runs Godot with a hard timeout, logs to out/<name>.log,
# and fails on a script error even if Godot itself exits 0.
run() {
  local name=$1 limit=$2; shift 2
  local extra=()
  # CI machines have no sound card.
  [ -n "${CI:-}" ] && extra=(--audio-driver Dummy)
  timeout "$limit" "$G" "${extra[@]}" "$@" > "out/$name.log" 2>&1
  local code=$?
  [ $code -eq 124 ] && echo "$name: TIMEOUT after ${limit}s" && code=1
  if grep -qE "SCRIPT ERROR|Parse Error|Failed to load script" "out/$name.log"; then
    echo "$name: script errors:"; grep -E "SCRIPT ERROR|Parse Error|Failed to load script" "out/$name.log" | head -10
    [ $code -eq 0 ] && code=1
  fi
  return $code
}

cmd=${1:-help}; shift || true
case "$cmd" in
  import)
    run import 600 --headless --path . --import; code=$?
    # A fresh import can report missing caches; what matters is that tests then load.
    exit 0 ;;

  check)
    fail=0
    echo "== draw lint: no raw slow draw calls in per-frame view code"
    hits=$(grep -nE '(^|[^A-Za-z_])(draw_circle|draw_arc|draw_colored_polygon|draw_polyline)\(' scripts/view/*.gd \
      | grep -v '^scripts/view/Terrain.gd:' | grep -v 'raw-draw-ok' | grep -vE '^[^:]+:[0-9]+:\s*#' || true)
    if [ -n "$hits" ]; then
      echo "$hits"
      echo "Use Draw.disc/ring/arc/poly/polyline instead (they cost 0.5-2 us; the raw calls 12-30 us each)."
      echo "A call that really must stay raw gets a '# raw-draw-ok: <why>' comment."
      fail=1
    else echo "ok"; fi
    echo "== design data in sync with design/*.md"
    node tools/tree_data.mjs > /dev/null && node tools/tree_page.mjs > /dev/null && node tools/super_page.mjs > /dev/null
    if ! git diff --quiet -- data/tower_trees.gd design/upgrade_trees.html design/super_structures.html; then
      git diff --stat -- data/tower_trees.gd design/upgrade_trees.html design/super_structures.html
      echo "Regenerated files differ: run the generators and commit their output with the .md change."
      fail=1
    else echo "ok"; fi
    echo "== version consistent"
    v=$(sed -n 's/^config\/version="\(.*\)"/\1/p' project.godot)
    pres=$(grep -c "application/file_version=\"$v.0\"" export_presets.cfg || true)
    if [ -z "$v" ] || [ "$pres" != "1" ]; then
      echo "project.godot says '$v' but export_presets.cfg file_version doesn't match: run tools/dev.sh version $v"
      fail=1
    else echo "ok ($v)"; fi
    exit $fail ;;

  test)
    run test 1200 --headless --path . res://tests/TestRunner.tscn -- "$@"; code=$?
    grep -E "^(FAIL|  FAILED)|checks, |^RESULT" out/test.log
    exit $code ;;

  tour)
    run tour 900 --path . -- --screenshot-tour; code=$?
    grep -E "CHECKS:|TOUR COMPLETE|^  FAIL" out/tour.log
    exit $code ;;

  compare)
    run compare 300 --path . -- --perf-compare; code=$?
    grep -E "TURRET COMPARE|DIFFERS" out/compare.log
    exit $code ;;

  perf)
    run perf 900 --path . -- "--perf-ci=$(pwd)/out/perf.json" || { tail -20 out/perf.log; exit 1; }
    node tools/perf_check.mjs out/perf.json "$@"
    exit $? ;;

  build)
    target=${1:-all}
    v=$(sed -n 's/^config\/version="\(.*\)"/\1/p' project.godot)
    mkdir -p build/linux
    if [ "$target" = windows ] || [ "$target" = all ]; then
      run export-windows 600 --headless --path . --export-release "Windows Desktop" build/BastionLine.exe || { tail -20 out/export-windows.log; exit 1; }
      echo "build/BastionLine.exe ($v)"
    fi
    if [ "$target" = linux ] || [ "$target" = all ]; then
      run export-linux 600 --headless --path . --export-release "Linux" build/linux/BastionLine.x86_64 || { tail -20 out/export-linux.log; exit 1; }
      # Pack with GNU tar so the binary is executable wherever it's unpacked (Windows has no exec bit).
      rm -rf out/pack && mkdir -p out/pack/BastionLine
      cp build/linux/BastionLine.x86_64 out/pack/BastionLine/ && cp fonts/OFL.txt out/pack/BastionLine/FONT-LICENSE-Barlow.txt
      (cd out/pack && tar --owner=0 --group=0 --mode=755 -cf ../BastionLine-linux-x86_64.tar BastionLine/BastionLine.x86_64 \
        && tar --owner=0 --group=0 --mode=644 -rf ../BastionLine-linux-x86_64.tar BastionLine/FONT-LICENSE-Barlow.txt)
      gzip -f out/BastionLine-linux-x86_64.tar && mv out/BastionLine-linux-x86_64.tar.gz build/
      echo "build/BastionLine-linux-x86_64.tar.gz ($v)"
    fi ;;

  version)
    v=${1:?usage: dev.sh version x.y.z}
    [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "version must be x.y.z"; exit 1; }
    sed -i "s/^config\/version=\".*\"/config\/version=\"$v\"/" project.godot
    sed -i "s/^application\/file_version=\".*\"/application\/file_version=\"$v.0\"/; s/^application\/product_version=\".*\"/application\/product_version=\"$v.0\"/" export_presets.cfg
    echo "version $v" ;;

  lx)
    # The owner playtests on Corundum-LX: every build gets its own folder inside the testing folder
    # there, named "<date> <time> <branch> (<commit>)" so the folders sort oldest to newest, with a
    # BUILD.txt saying what it is. Older builds are kept. LX is often off; then this says so and
    # succeeds.
    host=${LX_HOST:-swooshii@corundum-lx}
    root=${LX_DIR:-/home/swooshii/Documents/Bastion Line Testing}
    if ! ssh -o ConnectTimeout=8 -o BatchMode=yes "$host" true 2>/dev/null; then
      echo "Corundum-LX isn't reachable: build not copied"; exit 0
    fi
    "$0" build linux || exit 1
    v=$(sed -n 's/^config\/version="\(.*\)"/\1/p' project.godot)
    branch=$(git branch --show-current)
    commit=$(git rev-parse --short HEAD)
    dirty=""; git diff --quiet HEAD -- . ':!playtest' 2>/dev/null || dirty=" + uncommitted changes"
    name="$(date '+%Y-%m-%d %H%M') ${branch//\//-} ($commit)"
    rm -rf out/lx && mkdir -p out/lx
    cp build/linux/BastionLine.x86_64 out/lx/ && cp fonts/OFL.txt out/lx/FONT-LICENSE-Barlow.txt
    printf 'Bastion Line test build\nBranch:  %s\nCommit:  %s%s\nVersion: %s\nBuilt:   %s\n\nRun ./BastionLine.x86_64\n' \
      "$branch" "$commit" "$dirty" "$v" "$(date '+%Y-%m-%d %H:%M')" > out/lx/BUILD.txt
    # tar over ssh copes with the spaces in the folder names.
    tar -C out/lx -cf - . | ssh "$host" "mkdir -p \"$root/$name\" && cd \"$root/$name\" && tar --no-same-owner -xf - && chmod +x BastionLine.x86_64" \
      || { echo "copy to Corundum-LX failed"; exit 1; }
    echo "On Corundum-LX: $root/$name"
    sed 's/^/  /' out/lx/BUILD.txt | head -5 ;;

  *)
    sed -n '2,14p' "$0"; exit 1 ;;
esac
