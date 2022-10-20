#!/usr/bin/bash

TEMPDIR=$(mktemp -d)

cleanup() {
  echo "Removing $TEMPDIR"
  rm -rf $TEMPDIR
}
trap cleanup EXIT


function folder_of() {
  DIR="${1%/*}"
  (cd "$DIR" && echo "$(pwd -P)")
}

git -C $TEMPDIR clone https://github.com/simonmeggle/checkmk_template.git

CMD="rsync --archive --cvs-exclude --no-owner --no-group --no-times --verbose"
# Merge custom filters
if [ -e ".devcontainer/template-sync.conf" ]; then
    CMD="${CMD} --filter='merge .devcontainer/template-sync.conf'"
fi
# Default filter from repository
if [ -e "${TEMPDIR}/checkmk_template/.devcontainer/template-sync-includes.conf" ]; then
    CMD="${CMD} --filter='merge ${TEMPDIR}/checkmk_template/.devcontainer/template-sync-includes.conf'"
fi
CMD="${CMD} --filter='exclude *' ${TEMPDIR}/checkmk_template/ $(pwd)/"
bash -c "$CMD"

echo $CMD

echo "Creating default directories..."
for DIR in "agent_based" "agents" "bakery" "checkman" "checks" "checkman" "images" "web"; do
  mkdir -p $(pwd)/$DIR
done

PROJECT_DIR="$(dirname $(folder_of $0))"
PROJECT=${PROJECT_DIR##*/} 
echo "export PROJECT_NAME=$PROJECT" > $PROJECT_DIR/project.env