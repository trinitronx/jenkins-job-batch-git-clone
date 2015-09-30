Jenkins Job Batch Git Clone
===========================

A Ruby Script to query a Jenkins Server and find the jobs matching a particular filter.
Get the Git clone URL of each job and check them out to `/tmp/src`.

Available Environment Variables
-------------------------------

 - `GIT_CLONE_DIR`: Checkout repo to this directory **inside** the Docker Container. (Useful for [boot2docker][b2docker] / [docker-machine][docker-machine] running on a Mac with an automatic `/Users` shared directory from Host Mac -> Docker Host VM)
 - `GIT_CLONE_USER`: Checkout repo using this SSH username. (Translates to: `git clone ssh://${GIT_CLONE_USER}@host:port/path`)
 - `JENKINS_DEBUG`: Turns on extra info debug logging.
 - `JENKINS_HOST`: Jenkins Host to query for job list.
 - `JENKINS_JOB_FILTER`: A regex to filter what jobs to search for Git URIs. (Uses: `@client.job.list(jobs_to_filter)` from [jenkins_api_client][jenkins-api])
 - `JENKINS_PASSWORD`: Jenkins [API Access Token][jenkins-api-token]. Get one via: `http://jenkins.yourdomain.example.net/me/configure`
 - `JENKINS_PORT`: Port to access Jenkins API on.
 - `JENKINS_USER`: User to access Jenkins API with.


Example Usage
-------------

You will need an API token from your Jenkins Server to use this script.  To obtain one:

 - Go to: http://jenkins.example.net/user/me/configure
 - Click "`Show API Token...`"
 - Copy the API Token

Use the API Token as `JENKINS_PASSWORD` when running the container.

### Examples:

To checkout all repos listed in Jenkins Jobs matching '`foo`' to `~/src` on the Docker Host, run:

    docker run -ti -e JENKINS_HOST=jenkins.example.net -e JENKINS_USER=myjenkinsuser -e JENKINS_PASSWORD=1deadbeefbadc0de123456789abcd -e JENKINS_JOB_FILTER='foo' -v ~/src/:/tmp/src trinitronx/jenkins-job-batch-git-clone

To checkout all repos listed in Jenkins Jobs matching '`foo`' to `/Users/myboot2dockeruser/src` in the Docker Container, run:

    docker run -ti -e GIT_CHECKOUT_DIR=/Users/myboot2dockeruser/src -e JENKINS_HOST=jenkins.example.net -e JENKINS_USER=myjenkinsuser -e JENKINS_PASSWORD=1deadbeefbadc0de123456789abcd -e JENKINS_JOB_FILTER='foo' -v ~/src/:/tmp/src trinitronx/jenkins-job-batch-git-clone


To run in debug mode (shows extra info):

    docker run -ti -e JENKINS_DEBUG=1 -e JENKINS_HOST=jenkins.example.net -e JENKINS_USER=myjenkinsuser -e JENKINS_PASSWORD=1deadbeefbadc0de123456789abcd -e JENKINS_JOB_FILTER='foo' -v ~/src/:/tmp/src trinitronx/jenkins-job-batch-git-clone

To run in debug mode & test repo checkout only inside Docker Container's `/tmp/src` directory (doesn't checkout files to the Docker Host):

    docker run -ti -e JENKINS_DEBUG=1 -e JENKINS_HOST=jenkins.example.net -e JENKINS_USER=myjenkinsuser -e JENKINS_PASSWORD=1deadbeefbadc0de123456789abcd -e JENKINS_JOB_FILTER='foo' trinitronx/jenkins-job-batch-git-clone

[b2docker]: http://boot2docker.io/
[docker-machine]: https://docs.docker.com/machine/
[jenkins-api]: https://github.com/arangamani/jenkins_api_client
[jenkins-api-token]: https://wiki.jenkins-ci.org/display/JENKINS/Authenticating+scripted+clients