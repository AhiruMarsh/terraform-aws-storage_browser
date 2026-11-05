variable "prefix_name" {
  type        = string
  description = "Prefix name"
  default     = "storagebrowser"
}

variable "frontend_url" {
  type        = string
  description = "frontend URL"
  default     = null
}

variable "target_s3_bucket_name_list" {
  type        = list(string)
  description = "List of target S3 bucket name"
  default     = []
}

variable "cloudfront_function_arn" {
  type        = string
  description = "ARN of the CloudFront Function to associate with the viewer-request event of the default cache behavior (e.g. header restriction for development environments)"
  default     = null
}
