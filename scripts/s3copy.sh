#!/bin/bash
#Copy files either from local to S3 or from s3 to local downloads dir
src=${1?Enter the source}
dest=$2
if [[ $dest == s3://* ]]
then
	set -x
	aws s3 cp --sse AES256  $src $dest
	set +x
elif [[ $src == s3://* ]]
then
	mkdir -p downloads
	set -x
	aws s3 cp --recursive  $src downloads
	set +x
else
	echo "Either src or dest must be an s3 directory"
fi
