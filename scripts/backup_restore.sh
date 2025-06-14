#!/usr/bin/env bash

# Script to backup or restore XML files from a source directory to a target
# directory, preserving the directory structure.

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# The return value of a pipeline is the status of the last command to exit
# with a non-zero status, or zero if no command exited with a non-zero status.
set -o pipefail

# --- Helper Functions ---
function usage() {
    echo "Usage: $0 <command> <source_directory> <target_directory>"
    echo "Commands:"
    echo "  backup   Backs up XML files from source_directory to target_directory."
    echo "  restore  Restores XML files from source_directory (backup location) to target_directory."
    echo ""
    echo "Examples:"
    echo "  $0 backup /path/to/source_data /path/to/xml_backups"
    echo "  $0 restore /path/to/xml_backups /path/to/restored_data"
    exit 1
}

# --- Validate Source Function ---
function validate_source_dir() {
    local SOURCE_DIR="$1"

    # Validate source directory
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Error (backup): Source directory '$SOURCE_DIR' does not exist or is not a directory."
        return 1
    fi
}

# --- Copy Config Function ---
function copy_config() {
    local SOURCE_DIR="$1"
    local TARGET_DIR="$2"

    # Using rsync to synchronize XML files:
    # - Copies/updates XML files from source to target, preserving directory structure.
    # - Updates files in target only if the source version is newer (-u).
    # - Deletes *.xml files in target that are not present in the source.
    # - Non-XML files in the target directory are NOT deleted.
    # - Prunes empty directories in the target after operations.
    echo "Copying XML files using rsync for backup..."
    rsync -avu --delete \
        --include='*/' --include='*.xml' --exclude='*' \
        --filter='protect *' --filter='- protect *.xml' \
        --prune-empty-dirs "$SOURCE_DIR/" "$TARGET_DIR/"
}

# --- Backup Function ---
function backup_config() {
    local SOURCE_DIR="$1"
    local TARGET_DIR="$2"

    echo "Starting XML backup..."
    echo "Source: $SOURCE_DIR"
    echo "Target: $TARGET_DIR"

    validate_source_dir $SOURCE_DIR

    # Ensure source and target directories are not the same.
    if [ "$(realpath "$SOURCE_DIR")" == "$(realpath "$TARGET_DIR")" ]; then
        echo "Error (backup): Source and target directories cannot be the same."
        echo "Resolved source: $(realpath "$SOURCE_DIR")"
        echo "Resolved target: $(realpath "$TARGET_DIR")"
        return 1
    fi

    # Create target directory if it doesn't exist.
    mkdir -p "$TARGET_DIR"
    echo "Target directory for backup ensured: $TARGET_DIR"

    copy_config $SOURCE_DIR $TARGET_DIR

    echo "XML backup completed successfully to '$TARGET_DIR'."
}

# --- Restore Function ---
function restore_config() {
    local BACKUP_SOURCE_DIR="$1" # This is the backup location
    local RESTORE_TARGET_DIR="$2" # This is where files will be restored

    echo "Starting XML restore..."
    echo "Backup Source (from where to restore): $BACKUP_SOURCE_DIR"
    echo "Restore Target (to where to restore): $RESTORE_TARGET_DIR"

    validate_source_dir $BACKUP_SOURCE_DIR

    # Ensure backup source and restore target directories are not the same.
    if [ "$(realpath "$BACKUP_SOURCE_DIR")" == "$(realpath "$RESTORE_TARGET_DIR")" ]; then
        echo "Error (restore): Backup source and restore target directories cannot be the same."
        echo "Resolved backup source: $(realpath "$BACKUP_SOURCE_DIR")"
        echo "Resolved restore target: $(realpath "$RESTORE_TARGET_DIR")"
        return 1
    fi

    # Create restore target directory if it doesn't exist.
    mkdir -p "$RESTORE_TARGET_DIR"
    echo "Restore target directory ensured: $RESTORE_TARGET_DIR"

    copy_config $BACKUP_SOURCE_DIR $RESTORE_TARGET_DIR

    echo "XML restore completed successfully to '$RESTORE_TARGET_DIR'."
}

# --- Main Logic: Argument Parsing and Command Execution ---
if [ "$#" -ne 3 ]; then
    echo "Error: Incorrect number of arguments provided."
    usage
fi

COMMAND="$1"
ARG_SOURCE_DIR="$2"
ARG_TARGET_DIR="$3"

case "$COMMAND" in
    backup)
        backup_config "$ARG_SOURCE_DIR" "$ARG_TARGET_DIR"
        ;;
    restore)
        restore_config "$ARG_SOURCE_DIR" "$ARG_TARGET_DIR"
        ;;
    *)
        echo "Error: Invalid command '$COMMAND'."
        usage
        ;;
esac

exit 0
# --- End of Script ---
#
