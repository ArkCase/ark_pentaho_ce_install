# ArkCase Pentaho Installation

## How to build:

docker build _build-args_ -t ${BASE\_REGISTRY}/arkcase/pentaho-ee-install:latest .

### Build Arguments

The build requires S3 access credentials. Specifically, the following 3 build arguments must be set to the correct values:

* AWS\_ACCESS\_KEY\_ID
* AWS\_SECRET\_ACCESS\_KEY
* AWS\_SESSION\_TOKEN

For your account/role, some of the above values may be optional. There are also other optional build arguments realted to AWS services that can be set:

* AWS\_REGION
* S3\_BUCKET
* S3\_PATH
