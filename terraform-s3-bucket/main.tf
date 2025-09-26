###### AWS REGION ######
provider "aws" {
  region = var.aws_region
}



###### S3 RESOURCE CREATION ######
resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.bucket_name}-${random_id.rand.hex}"

}




#### THIS BLOCK WILL ADD 4 RANDOM BYTS AFTER BUCKET NAME TO AVOID BUCKET NAME CONFLICT ERROR ####
resource "random_id" "rand" {
  byte_length = 4
}




###### THIS BLOCK DEFINES THE OBJECT LOCK & ITS POLICY ######
resource "aws_s3_bucket_object_lock_configuration" "my_bucket_object_lock" {
  count  = var.enable_object_lock ? 1 : 0
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 365
    }
  }
}




###### THIS BLOCK ENABLE THE S3 BUCKET VERSIONING ######
resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}





###### THIS BLOCK ENABLE THE LIFECYCLE & DELETE THE FILES OLDER THAN 15 DAYS ######
resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  count = var.enable_lifecycle ? 1 : 0

  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "delete-old-files"
    status = "Enabled"

    filter {} #this filter block is to apply this lifecycle to all files under s3 bucket

    expiration {
      days = 15
    }
  }
}




########## BELOW 2 BLOCKS HELPS TO ENABLE THE ENCRYPTION ##########

###### THIS 1ST BLOCK WILL CREATE THE KMS KEY WHICH REQUIRED FOR ENCRYPTION ######
resource "aws_kms_key" "my_s3_key" {
  count = var.enable_kms_encryption ? 1 : 0

  description             = "KMS key for s3 encryption"
  deletion_window_in_days = 10
}


###### THIS 2ND BLOCK WILL USE ABOVE KMS KEY & ENABLE ENCRYPTION ######
resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  count = var.enable_kms_encryption ? 1 : 0

  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.my_s3_key[0].arn  #here we added [0] so that this key should access to its ARN ( under the key first line content will denine as 0, 2nd line 1 & so on - so we use 0 to use its arn)
    }
  }
}




###### THIS BLOCK ENABLE THE CORS & WORK AS PER THE DEFINED RULES ######
resource "aws_s3_bucket_cors_configuration" "my_bucket_cors" {
  count = var.enable_cors ? 1 : 0

  bucket = aws_s3_bucket.my_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
    allowed_origins = ["*"] #Here we need to define the domain to avoid security risks
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}




######## THIS BELOW 3 BLOCKS WILL ENABLE ACCESS LOGS ########

#### THIS 1ST BLOCK WILL LOOK FOR EXISTING CENTRAL LOG BUCKET WE CREATED MANUALLY ####
data "aws_s3_bucket" "central_log_target" {
  bucket = var.central_log_bucket_name
}


#### THIS 2ND BLOCK WILL GIVE PERMISSION TO THE CENTRAL LOG BUCKET WE CREATED MANUALLY ####
resource "aws_s3_bucket_acl" "central_log_bucket_acl" {
  bucket = var.central_log_bucket_name 
  acl    = "log-delivery-write" #we need to give this policy to central log bucket for log delivery
}


#### THIS 3RD BLOCK WILL ENABLE THE LOGGING ON THE NEW BUCKET AS PER THE INPUT RECEIVED 'TRUE' Or 'FALSE'
resource "aws_s3_bucket_logging" "data_bucket_log_config" {
  count = var.enable_access_log ? 1 : 0 
  bucket = aws_s3_bucket.my_bucket.id 
  target_bucket = data.aws_s3_bucket.central_log_target.id
  
  target_prefix    = "${aws_s3_bucket.my_bucket.id}-access-logs/"  #this will create sub-folder base on bucket id name & store the logs
}