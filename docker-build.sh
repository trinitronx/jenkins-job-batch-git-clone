#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
docker build -t trinitronx/jenkins-job-batch-git-clone:latest $DIR
