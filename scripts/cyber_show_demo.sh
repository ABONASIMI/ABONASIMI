#!/usr/bin/env bash
set -euo pipefail

# ============================================================
#  DEMO / SIMULATION ONLY
#  This is just a visual terminal animation for fun.
#  - No hacking
#  - No network activity
#  - No real credentials
#  Everything stays inside: ~/demo_lab/
# ============================================================

SESSION="cyberdemo"
LAB="$HOME/demo_lab"
SRC="$LAB/source"
DST="$LAB/backup"
LOG="$LAB/demo.log"

GREEN="\033[1;32m"
DIM="\033[2m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

need(){ command -v "$1" >/dev/null 2>&1; }
ts(){ date +"%H:%M:%S"; }
randhex(){ head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n'; }

banner(){
  clear
  echo -e "${GREEN}====================  DEMO / SIMULATION  ====================${RESET}"
  echo -e "${DIM}This is a visual animation only. No hacking, no network, no real credentials.${RESET}"
  echo -e "${RED}>>> SIMULATION MODE (FOR FUN / VIDEO AESTHETIC) <<<${RESET}"
  echo
  echo -e "${DIM}Workspace:${RESET} ${CYAN}${LAB}${RESET}"
  echo
}

logline(){
  mkdir -p "$LAB"
  local line="[$(ts)] $*"
  echo -e "$line" | tee -a "$LOG" >/dev/null
}

seed_files(){
  mkdir -p "$SRC"/{pictures,downloads,documents,projects,keys,logs,tmp} "$DST"
  : > "$LOG"
  echo "DEMO / SIMULATION ONLY" > "$LAB/README_DEMO.txt"

  # small real sample files (NOT thousands)
  for i in $(seq 1 12); do
    head -c $(( (RANDOM%6000)+2000 )) /dev/urandom > "$SRC/pictures/img_${i}.raw" 2>/dev/null || true
  done
  for i in $(seq 1 8); do
    head -c $(( (RANDOM%9000)+4000 )) /dev/urandom > "$SRC/downloads/dl_${i}.bin" 2>/dev/null || true
  done
  for i in $(seq 1 10); do
    printf "DEMO DOCUMENT %02d\nhash:%s\n" "$i" "$(randhex)" > "$SRC/documents/doc_${i}.txt"
  done

  # fake demo secrets (local only)
  {
    echo "DEMO_TOKEN=SIM-$(randhex)-$(randhex)"
    echo "DEMO_KEY_FRAGMENT=K-$(randhex)"
    echo "NOTE: Fake data for aesthetics."
  } > "$SRC/keys/demo_secrets_source.txt"

  for i in $(seq 1 20); do
    echo "[$(ts)] event_${i} :: $(randhex)" >> "$SRC/logs/app.log"
  done
}

# Exact 10 seconds bar: 100 steps x 0.1s
progress10(){
  local label="$1"
  local width=32
  local p=0
  while [ "$p" -le 100 ]; do
    local filled=$(( p * width / 100 ))
    local empty=$(( width - filled ))
    local bar space
    bar="$(printf "%0.s#" $(seq 1 "$filled") 2>/dev/null || true)"
    space="$(printf "%0.s-" $(seq 1 "$empty") 2>/dev/null || true)"

    printf "\r${CYAN}%-48s${RESET} [${GREEN}%s${RESET}${DIM}%s${RESET}] ${YELLOW}%3d%%%s" \
      "$label" "$bar" "$space" "$p" "$RESET"

    [ "$p" -eq 100 ] && break
    p=$((p+1))
    sleep 0.1
  done
  echo
}

simulate_folder(){
  local name="$1"
  local virtual_total="$2"

  local src_path="$SRC/$name"
  local dst_path="$DST/$name"
  mkdir -p "$dst_path"

  logline "${YELLOW}--- Simulated copy (DEMO) ---${RESET}"
  logline "SRC: $src_path"
  logline "DST: $dst_path"
  logline "FILES (virtual): $virtual_total"
  logline "DURATION: 10s"
  logline ""

  # per-second log updates (10 seconds)
  local copied=0
  local inc=0
  for sec in $(seq 1 10); do
    inc=$(( (RANDOM % 220) + 80 ))
    copied=$((copied + inc))
    local max_now=$(( sec * virtual_total / 10 ))
    [ "$copied" -gt "$max_now" ] && copied="$max_now"
    [ "$copied" -gt "$virtual_total" ] && copied="$virtual_total"
    logline "copy:${name}  ${copied}/${virtual_total} files  | chunk=$(randhex)"
    sleep 1
  done
  logline "copy:${name}  ${virtual_total}/${virtual_total} files  | COMPLETE"
  logline ""

  progress10 "Copying folder: $name (virtual $virtual_total files)"
  # copy only sample files (safe)
  cp -a "$src_path/." "$dst_path/" 2>/dev/null || true

  echo -e "${DIM}  * checksum:${RESET} ${GREEN}$(randhex)$(randhex)${RESET}"
  logline "checksum:${name} $(randhex)$(randhex)"
  logline ""
}

run_demo(){
  seed_files
  banner

  progress10 "Indexing local project files"
  echo -e "${DIM}  * checksum:${RESET} ${GREEN}$(randhex)$(randhex)${RESET}"
  echo

  # each folder takes 10 seconds (virtual counts)
  simulate_folder "pictures" 2000
  simulate_folder "downloads" 850
  simulate_folder "documents" 420
  simulate_folder "projects" 120
  simulate_folder "logs" 900
  simulate_folder "tmp" 300

  progress10 "Copying DEMO secrets: keys/demo_secrets_source.txt -> passwords.txt"
  cp -f "$SRC/keys/demo_secrets_source.txt" "$DST/passwords.txt"
  echo -e "${DIM}  * checksum:${RESET} ${GREEN}$(randhex)$(randhex)${RESET}"
  echo

  echo -e "${GREEN}DONE (demo).${RESET}"
  echo -e "${DIM}Backup folder:${RESET} ${CYAN}$DST${RESET}"
  echo -e "${DIM}Log file:${RESET} ${CYAN}$LOG${RESET}"
}

files_view(){
  mkdir -p "$LAB"
  while true; do
    clear
    echo -e "${GREEN}====================  DEMO / SIMULATION  ====================${RESET}"
    echo -e "${DIM}Live view (safe) - everything is inside ~/demo_lab/${RESET}"
    echo
    echo -e "${CYAN}SRC:${RESET} $SRC"
    echo -e "${CYAN}DST:${RESET} $DST"
    echo
    echo -e "${YELLOW}Virtual counts (aesthetic):${RESET}"
    echo "pictures : 2000"
    echo "downloads:  850"
    echo "documents:  420"
    echo "projects :  120"
    echo "logs     :  900"
    echo "tmp      :  300"
    echo
    echo -e "${CYAN}Latest files in backup (real sample files):${RESET}"
    find "$DST" -maxdepth 2 -type f -printf "%TY-%Tm-%Td %TH:%TM  %8s  %p\n" 2>/dev/null | tail -n 25 || true
    sleep 1
  done
}

run_dashboard(){
  if ! need tmux; then echo "Install tmux: sudo apt install tmux"; exit 1; fi
  if ! need cmatrix; then echo "Install cmatrix: sudo apt install cmatrix"; exit 1; fi

  tmux kill-session -t "$SESSION" 2>/dev/null || true

  # Left: btop/top
  tmux new-session -d -s "$SESSION" "btop 2>/dev/null || top"

  # Right column
  tmux split-window -h -t "$SESSION":0
  tmux resize-pane -t "$SESSION":0.0 -R 35 2>/dev/null || true

  # Right -> 3 rows (total 4 panes)
  tmux select-pane -t "$SESSION":0.1
  tmux split-window -v -t "$SESSION":0.1
  tmux select-pane -t "$SESSION":0.1
  tmux split-window -v -t "$SESSION":0.1

  local script_path
  script_path="$(readlink -f "$0")"

  # Top-right: cmatrix exactly as requested
  tmux send-keys -t "$SESSION":0.1 "cmatrix -b -s" C-m

  # Mid-right: files view
  tmux send-keys -t "$SESSION":0.3 "bash '$script_path' --files" C-m

  # Bottom-right: demo progress
  tmux send-keys -t "$SESSION":0.2 "bash '$script_path' --demo" C-m

  tmux attach -t "$SESSION"
}

case "${1:-}" in
  --demo)  run_demo ;;
  --files) files_view ;;
  *)       run_dashboard ;;
esac
