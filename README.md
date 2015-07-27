Jenkins Job Batch Git Clone
===========================

A Ruby Script to query a Jenkins Server and find the jobs matching a particular filter.
Get the Git clone URL of each job and check them out to `/tmp/src`.


Example Usage
-------------

To run:

    sudo docker run -ti -e JENKINS_DEBUG=1 -e JENKINS_USER=myjenkinsuser -e JENKINS_PASSWORD=1deadbeefbadc0de123456789abcd   trinitronx/jenkins-job-batch-git-clone
