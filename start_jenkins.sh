#!/bin/bash
# Start from home directory
cd ~
rm -rf jenkins_demo/

# Install java
sudo apt-get update -y || true
sudo apt-get install -y openjdk-8-jre

# Clone the repo
git clone https://github.com/TheConstructAi/jenkins_demo.git

# Run Jenkins
cd jenkins_demo
JENKINS_HOME=. java -jar jenkins.war &
JENKINS_PID=$!
sleep 15s

# Call the jenkins job
INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
echo "$INSTANCE_ID"
URL=`echo "http://$INSTANCE_ID.robotigniteacademy.com:$SLOT_JENKINS_PORT"`
echo "$URL/buildByToken/build?job=TestJob&token=J3nkinsT0k3n"
curl -X POST "$URL/buildByToken/build?job=TestJob&token=J3nkinsT0k3n"

# Wait for 30 secs, kill Jenkins and clean up
sleep 40s
kill $JENKINS_PID &
cd ~
sleep 5s
rm -rf jenkins_demo/
