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

variable "custom_domain_name" {
  type        = string
  description = "Custom domain name (FQDN) for the CloudFront distribution. When set, an ACM certificate is issued in us-east-1 and attached to the distribution"
  default     = null
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID of custom_domain_name. When set, ACM DNS validation records and alias records (A/AAAA) are created automatically. When null, register the records in acm_validation_records in your own DNS (apply waits until the certificate is validated)"
  default     = null
}
