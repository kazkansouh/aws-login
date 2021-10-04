#!/bin/bash

# Copyright (C) 2021 Karim Kanso. All Rights Reserved.
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

if [[ $# -ne 1 || ! "$1" =~ ^[0-9]{6}$ || "${BASH_SOURCE[0]}" == "${0}" ]] ; then
    1>&2 echo "usage: source $(basename -- $0) MFACODE"
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]] ; then
        exit 1
    else
        return
    fi
fi

# dont remove this line
unset AWS_SESSION_TOKEN

# update or remove the below if they are set already external
export AWS_ACCESS_KEY_ID=AKEXAMPLEEXAMPLE
export AWS_REGION=eu-west-2
export AWS_DEFAULT_REGION=${AWS_REGION}
export AWS_SECRET_ACCESS_KEY=EXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLEEXAMPLE

# update this
MFA=arn:aws:iam::123456789:mfa/EXAMPLE

eval $(aws sts get-session-token --serial-number "${MFA}" --token-code "$1" --duration-seconds $((60*60*24)) | jq -r '.Credentials | [ "AWS_ACCESS_KEY_ID=\(.AccessKeyId)", "AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)", "AWS_SESSION_TOKEN=\(.SessionToken)" ][] | "export \(.)"')

if test -n "${AWS_SESSION_TOKEN}" ; then
    echo -n 'checking login: '
    aws iam get-user | jq -r .User.Arn
else
    echo 'session not set'
fi
