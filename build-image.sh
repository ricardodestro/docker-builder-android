export REPOSITORY_NAME="macielbombonato"
export SERVICE_NAME="docker-androidsdk-base"
export VERSION="27.0.3"

export DOCKER_FILE="."

echo 'Building image'
docker build --rm -t ${REPOSITORY_NAME}/${SERVICE_NAME}:${VERSION} ${DOCKER_FILE}