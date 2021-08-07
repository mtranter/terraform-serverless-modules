# Sets up Snowpipe / S3 integration

Usage:
```
provider "snowflake" {
    username = "???"
    password = "???"
    role = "accountadmin" // Must be account Admin
    region = "ap-southeast-2"
    account = "???"
}

provider "aws" {
    region = "ap-southeast-2"
}

module "pipe" {
    source = "./s3-to-snowflake"
    bucket_name = "test-bucket" // set create_bucket = false for existing bucket
    // create_bucket = false
    bucket_region = "ap-southeast-2"
    copy_statement = <<EOF
copy into test.raw.TEST_PIPE
from @test.raw.TEST_STAGE
EOF
    create_bucket = true
    file_format = "TYPE = CSV SKIP_HEADER = 1"
    job_name = "TestSnowpipe"
    pipe_database = "TEST"
    pipe_name = "TEST_PIPE"
    pipe_schema = "RAW"
    stage_database = "TEST"
    stage_name = "TEST_STAGE"
    stage_schema = "RAW"
}
```
