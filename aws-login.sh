#!/bin/bash

# Copyright (C) 2022 Karim Kanso. All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [[ $# -lt 1 || ! "$1" =~ ^[0-9]{6}$ || "${BASH_SOURCE[0]}" == "${0}" ]] ; then
    1>&2 echo "usage: source $(basename -- $0) MFACODE [aws-region]"
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]] ; then
        exit 1
    else
        return
    fi
fi

# dont remove this line
unset AWS_SESSION_TOKEN

# update or remove the below if access key is already set (e.g. config file)
SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
if test -f "${SCRIPT_DIR}/.env"; then
    . "${SCRIPT_DIR}/.env"
else
  # Or simply define AWS access key in this file
  export AWS_ACCESS_KEY_ID=AKEXAMPLEEXAMPLE
  export AWS_SECRET_ACCESS_KEY=EXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLE
fi

if test "${AWS_ACCESS_KEY_ID}" = "AKEXAMPLEEXAMPLE" ; then
    2>&1 echo "AWS access key not set."
    exit 1
fi

# set region if required
if test -z "${AWS_REGION}" -o -n "${2}"; then
    export AWS_REGION=${2:-eu-west-2}
    export AWS_DEFAULT_REGION=${AWS_REGION}
fi

if test -z "${MFA}"; then
    # update this
    MFA=arn:aws:iam::123456789:mfa/EXAMPLE
fi

eval $(aws sts get-session-token --serial-number "${MFA}" --token-code "$1" --duration-seconds $((60*60*24)) | jq -r '.Credentials | [ "AWS_ACCESS_KEY_ID=\(.AccessKeyId)", "AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)", "AWS_SESSION_TOKEN=\(.SessionToken)" ][] | "export \(.)"')

if test -n "${AWS_SESSION_TOKEN}" ; then
    echo -n 'checking login: '
    aws iam get-user | jq -r .User.Arn
else
    echo 'session not set'
fi
