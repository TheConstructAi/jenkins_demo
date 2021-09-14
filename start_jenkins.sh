#! /bin/bash
# Start from home directory
cd ~

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
curl -X POST "http://$(instance_id).robotigniteacademy.com:${SLOT_JENKINS_PORT}/buildByToken/build?job=TestJob&token=J3nkinsT0k3n"

# Wait for 30 secs, kill Jenkins and clean up
sleep 30s
kill $JENKINS_PID
cd ~
rm -rf jenkins_demo
