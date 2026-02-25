#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

CONFIG_DIRS=(
    "configs/planet_nearmap_448"
)
PBS_SCRIPT="tools/test_single_gpu_planet_nearmap_448.pbs"
EMAIL_TO="z5428587@ad.unsw.edu.au"
WORK_DIR_BASE=""
CHECKPOINT=""
QSUB_RESOURCES="select=1:ncpus=6:ngpus=1:mem=32gb:gpu_model=A100"
DRY_RUN="0"
CUSTOM_CONFIG_DIRS="0"

usage() {
    cat <<'EOF'
Usage: tools/submit_planet_nearmap_448_test.sh [options]

Options:
  --config-dir <path>          Config directory to scan for .py files.
                               Repeat to include multiple directories.
                               If provided, overrides default directories.
  --email <addr>               Email for PBS failure notifications.
  --work-dir-base <path>       Optional WORK_DIR_BASE override.
  --checkpoint <path>          Optional checkpoint for all configs.
  --resources "<pbs string>"   qsub -l resources string.
  --dry-run                    Print qsub commands without submitting.
  --help                       Show this message.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --config-dir)
            if [[ "$CUSTOM_CONFIG_DIRS" != "1" ]]; then
                CONFIG_DIRS=()
                CUSTOM_CONFIG_DIRS="1"
            fi
            CONFIG_DIRS+=("$2")
            shift 2
            ;;
        --email)
            EMAIL_TO="$2"
            shift 2
            ;;
        --work-dir-base)
            WORK_DIR_BASE="$2"
            shift 2
            ;;
        --checkpoint)
            CHECKPOINT="$2"
            shift 2
            ;;
        --resources)
            QSUB_RESOURCES="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN="1"
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ ! -f "$PBS_SCRIPT" ]]; then
    echo "ERROR: PBS script not found: $PBS_SCRIPT" >&2
    exit 1
fi

CONFIGS=()
for config_dir in "${CONFIG_DIRS[@]}"; do
    if [[ ! -d "$config_dir" ]]; then
        echo "ERROR: Config directory not found: $config_dir" >&2
        exit 1
    fi
    while IFS= read -r cfg; do
        CONFIGS+=("$cfg")
    done < <(find "$config_dir" -maxdepth 1 -type f -name '*.py' | sort)
done

if [[ ${#CONFIGS[@]} -gt 0 ]]; then
    sorted_configs=()
    while IFS= read -r cfg; do
        sorted_configs+=("$cfg")
    done < <(printf '%s\n' "${CONFIGS[@]}" | sort -u)
    CONFIGS=("${sorted_configs[@]}")
fi

if [[ ${#CONFIGS[@]} -eq 0 ]]; then
    echo "ERROR: No config files found in configured directories." >&2
    exit 1
fi

echo "Submitting ${#CONFIGS[@]} test config(s) from:"
for config_dir in "${CONFIG_DIRS[@]}"; do
    echo "  - $config_dir"
done
echo "PBS script: $PBS_SCRIPT"
echo "Resources: $QSUB_RESOURCES"
echo "Single-node/single-GPU: yes"
echo "Dry-run: $DRY_RUN"
echo

for cfg in "${CONFIGS[@]}"; do
    rel_cfg="${cfg#${REPO_ROOT}/}"
    env_vars="CONFIG_YAML=${rel_cfg},EMAIL_TO=${EMAIL_TO}"
    if [[ -n "$WORK_DIR_BASE" ]]; then
        env_vars="${env_vars},WORK_DIR_BASE=${WORK_DIR_BASE}"
    fi
    if [[ -n "$CHECKPOINT" ]]; then
        env_vars="${env_vars},CHECKPOINT=${CHECKPOINT}"
    fi

    cmd=(qsub -l "$QSUB_RESOURCES" -V -v "$env_vars" "$PBS_SCRIPT")
    echo "Config: $(basename "$cfg")"
    echo "  ${cmd[*]}"
    if [[ "$DRY_RUN" != "1" ]]; then
        "${cmd[@]}"
    fi
    echo
done
