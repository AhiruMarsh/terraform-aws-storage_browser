# Restricted header
variable "restricted_header_name" {
  type        = string
  description = "Header name required to access CloudFront"
}

variable "restricted_header_value" {
  type        = string
  description = "Header value required to access CloudFront"
  sensitive   = true
}

resource "aws_cloudfront_function" "restricted_header" {
  name = "${var.prefix_name}-frontend-restricted"

  runtime = "cloudfront-js-2.0"
  code = templatefile(
    "functions/restrictedHeader.js.tftpl",
    {
      HEADER_NAME  = var.restricted_header_name
      HEADER_VALUE = var.restricted_header_value
    }
  )
}
