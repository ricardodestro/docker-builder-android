#!/bin/sh

update-ca-certificates

export PATH=$PATH:/opt/sonar-scanner/bin

# Bellow some variables that you need to fil in your environment
export ANDROID_SDK_HOME="/opt/android-sdk"
#export ARTIFACTORY_URL="..."
#export ARTIFACTORY_USERNAME="..."
#export ARTIFACTORY_PASSWORD="..."

#export CRASHLYTICS_KEY="..."
#export KEY_ALIAS="..."
#export KEY_PASSWORD="..."

#export SLACK_URL="..."
#export DELIVER_USER="..."

#export SONAR_URL="..."
#export SONAR_LOGIN="..."

# You must set commented variables in your environment
# this variables are necessary to make your environment as a Jenkins Slave
export JENKINS_JAR_NAME="slave.jar"
#export JENKINS_HOST="http://..."
#export JENKINS_SECRET="..."
export JENKINS_AGENT_HOME="/opt/slave"
export JENKINS_AGENT_WORKDIR="/opt/app"
#export JENKINS_AGENT_NAME="..."

# Download do conector do agente
curl ${JENKINS_HOST}/jnlpJars/slave.jar -o "${JENKINS_AGENT_HOME}/${JENKINS_JAR_NAME}" --insecure

# Execucao do agente
java -jar ${JENKINS_AGENT_HOME}/${JENKINS_JAR_NAME} \
    -jnlpUrl ${JENKINS_HOST}/computer/${JENKINS_AGENT_NAME}/slave-agent.jnlp \
    -secret ${JENKINS_SECRET} \
    -workDir ${JENKINS_AGENT_WORKDIR} \
    -noCertificateCheck
