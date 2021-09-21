#!/bin/bash

# Exit on any error. If something fails, there's no use
# proceeding further because Jenkins might not be able 
# to run in that case
set -e

# And then set the JENKINS_HOME environment variable. This will cause
# Jenkins will run from this directory.
# Create the JENKINS_HOME directory if it doesn't exist.
export JENKINS_HOME=~/webpage_ws/jenkins
mkdir -p $JENKINS_HOME

# Install java. We are using JRE 8.
sudo apt-get update -y || true
sudo apt-get install -y openjdk-8-jre

# Download the Jenkins .war file, if not there already
cd ~/webpage_ws/jenkins/
JENKINS_FILE="$JENKINS_HOME/jenkins.war"
if [ ! -f "$JENKINS_FILE" ]; then
    wget https://updates.jenkins.io/download/war/2.303.1/jenkins.war
fi

# Jenkins is about to run, but we must check if 
# it's is already running
string=`ps ax | grep jenkins`
if [[ $string == *"jenkins.war"* ]]; then
    # Don't proceed further. Jenkings is already running
    echo "Jenkins is running already. Exiting."
    exit 0
else
    # Start Jenkins, since it's not running yet. 
    # Run Jenkins ith a prefix. A prefix is needed because we are using a 
    # reverse proxy to run it on the Academy (this may not be necessary in your setup)
    # Store Jenkins proceess ID in JENKINS_PID
    java -jar jenkins.war --prefix="/$SLOT_PREFIX/jenkins/" &
    JENKINS_PID=$!
    sleep 15s

    # Calculate the Jenkins proxy address
    # This is NOT required for running Jenkins. It's just something we
    # need to do on the Academy. INSTANCE_ID and SLOT_PREFIX are Academy variables.
    INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
    URL=`echo "https://$INSTANCE_ID.robotigniteacademy.com/$SLOT_PREFIX/jenkins/"`
    echo ""
    echo "1. Jenkins is running in the background."
    echo "2. Switch to the webpage tab to see it."

    # Create a file that will store vital information
    # about the Jenkins instance
    # Save the running instance info to the file
    # This is just for your convenience
    STATE_FILE=~/jenkins__pid__url.txt
    touch $STATE_FILE
    echo "To kill Jenkins, run:" > $STATE_FILE
    echo "kill $JENKINS_PID" >> $STATE_FILE
    echo "" >> $STATE_FILE
    echo "Jenkins URL: " >> $STATE_FILE
    echo $URL >> $STATE_FILE
    echo "3. See '$STATE_FILE' for Jenkins PID and URL."

    # PLEASE DON'T DO THIS ON YOUR PRIVATE SERVER
    # This is to ensure all Jenkins config files are saved for the
    # next session on the Academy
    chmod -R 777 $JENKINS_HOME
    rm -rf ~/run_jenkins* || true
fi
