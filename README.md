# Request AWS Session Token with MFA

Simple script that requests an AWS token using STS and sets environment variables.

# Usage

Prerequisites, install AWSCLI and `jq`.

First, setup an administrator permissions AWS policy such as:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": "true"
                },
                "IpAddress": {
                    "aws:SourceIp": "1.2.3.4"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "aws:ViaAWSService": "true"
                }
            }
        }
    ]
}
```

The IP address block is optional, but provides added security if its
possible to limit the scope to a single IP address. Also, its possible
to add additional restrictions such as maximum age of MFA session
token.

Assign this policy to a user.

Then, download the `aws-login.sh` script and either remove the
exported environment variables (if AWS credentials are correctly
setup) or update with your access key/secret. Also, update the `MFA`
variable to your `MFA` identifier.

Then run the following from a bash shell:

```
. ./aws-login.sh 123456
```

Here, 123456 is the MFA token.

This will set a number of environment variables in the current
shell. Importantly it will setup the session token. Afterwards it
should be possible to use AWSCLI commands normally.

# Other bits

Copyright Karim Kanso, 2021. All rights reserved. Code licensed under
GPLv3.
