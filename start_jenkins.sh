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
JENKINS_HOME=. java -jar jenkins.war --prefix="/$SLOT_PREFIX/jenkins/" &
JENKINS_PID=$!
sleep 15s

# Call the jenkins job
INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
URL=`echo "https://$INSTANCE_ID.robotigniteacademy.com/$SLOT_PREFIX/jenkins"`
curl -X POST "$URL/buildByToken/build?job=TestJob&token=J3nkinsT0k3n"

# Wait for 45 secs, kill Jenkins and clean up
sleep 45s
kill $JENKINS_PID &
cd ~
sleep 5s
rm -rf jenkins_demo/
