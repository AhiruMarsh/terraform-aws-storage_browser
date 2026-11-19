variable "prefix_name" {
  type        = string
  description = "Prefix name"
  default     = "storagebrowser"
}

variable "frontend_url" {
  type        = string
  description = "Frontend URL"
  default     = null
}

variable "custom_domain_name" {
  type        = string
  description = "Custom domain name (FQDN) for CloudFront"
  default     = null
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID of the custom domain"
  default     = null
}
