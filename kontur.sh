#!/bin/bash

REPO_PATH="https://github.com/mkosterin/testcase-pybash"
WORK_DIR_PATH=`echo $REPO_PATH | sed 's@.*/@@'`
HOST_PORT="81"
SLEEP_TIME="30"


function buildImage {
##cd $WORK_DIR_PATH
	commitID=$(git log --all --pretty=format:"%h" -n 1)
	echo $commitID
	authorID=$(git log --all --pretty=format:"%an" -n 1)
	echo $authorID
	git pull --all
	branchID=$(git branch --contains $commitID 2>&1 | awk -v FS=' ' '/\*/{print $NF}' | sed 's|[()]||g')
	echo $branchID
  #build new version
	git checkout $branchID
  cd ..
	tagID="mkv/kontur:$commitID"
	echo $tagID
	docker build . -t ${tagID} --label "branch=$branchID" --label "commit hashID=$commitID" --label "maintainer=$authorID"
  deployApp
}

function deployApp {
  docker ps | grep kontur | awk '{print $1}' | xargs docker stop
	docker run -d --rm -p $HOST_PORT:80 $tagID 
}

function repoClone {
	if [ -d $WORK_DIR_PATH ]; then 
		cd $WORK_DIR_PATH
		#git pull --all
		echo Repo already exists
		cd ..
  else
		git clone $REPO_PATH.git
	fi
}

function commitCheck {
  cd $WORK_DIR_PATH
#	retVal=$(git fetch --all 2>&1 | wc -l)
  retVal=$(git pull --all 2>&1 | wc -l)
	echo $retVal
	if [ "$retVal" -gt "3" ]; then
		echo "New comit has been found"
    echo "We need to build/deploy new release"    
    buildImage
	else
		echo "New comit has not been found"
		echo "Nothing to do"
    cd ..
	fi
}

repoClone
while true
do
  commitCheck
	sleep $SLEEP_TIME
done



