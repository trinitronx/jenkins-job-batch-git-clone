Jenkins Job Batch Git Clone
===========================

A Ruby Script to query a Jenkins Server and find the jobs matching a particular filter.
Get the Git clone URL of each job and check them out to `/tmp/src`.

Available Environment Variables
-------------------------------

 - `GIT_CLONE_DIR`: Checkout repo to this directory **inside** the Docker Container.<br/> (Useful for [boot2docker][b2docker] / [docker-machine][docker-machine] running on a Mac with an automatic `/Users` shared directory from Host Mac -> Docker Host VM)
 - `GIT_CLONE_USER`: Checkout repo using this SSH username.<br/> (Translates to: `git clone ssh://${GIT_CLONE_USER}@host:port/path`)
 - `GIT_CLONE_FQDN`: Default FQDN to use for short hostnames found for git repo URIs.<br/> (Useful when short hostnames are found in Jenkins Job git URIs which are not resolvable from the Docker Container)
 - `JENKINS_DEBUG`: Turns on extra info debug logging.
 - `JENKINS_HOST`: Jenkins Host to query for job list.
 - `JENKINS_JOB_FILTER`: A regex to filter what jobs to search for Git URIs.<br/> (Uses: `@client.job.list(jobs_to_filter)` from [jenkins_api_client][jenkins-api])
 - `JENKINS_PASSWORD`: Jenkins [API Access Token][jenkins-api-token].<br/> Get one via: `http://jenkins.yourdomain.example.net/me/configure`
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


Known Issues / TODO
-------------------

If cloning via SSH URI, or private repos git credentials can prevent an easy batch clone.  You will need to pass through your git SSH keys, or use `ssh-agent`.  In the case of GitHub, you may choose to use a [GitHub API Token][github-api-token].

A good place to start is to run `ssh-agent` on either the Docker Host machine, or on the Hosting physical machine that is running [`boot2docker`][b2docker] or [`docker-machine`][docker-machine].  You will then need to pass through the `$SSH_AUTH_SOCK` environment variable, and mount the actual socket file as a [docker volume][docker-volumes] into the Docker Container.  The [method][docker-ssh-agent] for doing this depends on where you are running the `docker` daemon (e.g.: [`boot2docker`][b2docker] on a Mac / physical machine, [`docker-machine`][docker-machine] on a Mac / physical machine, inside another Linux VM, on a physical machine, etc...)

Here are some helpful methods:

 - [If using `docker` daemon on physical or VM host][docker-ssh-forward]
 - [If using `boot2docker`][b2docker-ssh-agent], or [this script][b2docker-ssh-agent-script]
 - [If using `docker-machine`][docker-machine-ssh-agent]

[b2docker]: http://boot2docker.io/
[docker-machine]: https://docs.docker.com/machine/
[jenkins-api]: https://github.com/arangamani/jenkins_api_client
[jenkins-api-token]: https://wiki.jenkins-ci.org/display/JENKINS/Authenticating+scripted+clients
[docker-volumes]: http://container-solutions.com/understanding-volumes-docker/
[docker-ssh-agent]: http://stackoverflow.com/q/27036936/645491
[docker-ssh-forward]: https://gist.github.com/d11wtq/8699521
[b2docker-ssh-agent]: https://gist.github.com/d11wtq/8699521#gistcomment-1424725
[b2docker-ssh-agent-script]: https://gist.github.com/rcoup/53e8dee9f5ea27a51855
[docker-machine-ssh-agent]: https://gist.github.com/leedm777/923706741c8296869e7d
[github-api-token]: https://github.com/blog/1509-personal-api-tokens
