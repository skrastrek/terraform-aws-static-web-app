variable "name_prefix" {
  type = string
}

variable "acm_certificate_arn_us_east_1" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "domain_name_zone_id" {
  type = string
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "www_redirect_enabled" {
  type        = bool
  default     = false
  description = "Enable a 301 redirect from www.<domain_name> to <domain_name>. The ACM certificate must cover the www subdomain."

  # CloudFront allows only one viewer-request trigger (function or Lambda@Edge) per
  # cache behavior. The www redirect occupies that slot on every behavior, so it
  # cannot coexist with any other viewer-request association.
  validation {
    condition = !var.www_redirect_enabled || !contains(flatten([
      var.auth_default_cache_behaviour != null ? [var.auth_default_cache_behaviour.event_type] : [],
      var.auth_ordered_cache_behaviours[*].event_type,
      [for b in concat(var.s3_bucket_ordered_cache_behaviours, var.custom_ordered_cache_behaviours) : [
        b.function_associations[*].event_type,
        b.lambda_function_associations[*].event_type,
      ]],
    ]), "viewer-request")
    error_message = "www_redirect_enabled cannot be combined with any viewer-request association (auth_default_cache_behaviour, auth_ordered_cache_behaviours, or any viewer-request function/Lambda@Edge in s3_bucket_/custom_ordered_cache_behaviours). CloudFront permits only one viewer-request trigger per cache behavior, which the www redirect occupies."
  }
}

variable "spa_enabled" {
  type        = bool
  description = "Enable or disable SPA-specific features."
}

variable "spa_custom_error_response_codes" {
  type = list(number)
}

variable "auth_default_cache_behaviour" {
  type = object({
    lambda_arn   = string
    event_type   = optional(string, "viewer-request")
    include_body = optional(bool, false)
  })
  default = null
}

variable "auth_ordered_cache_behaviours" {
  type = list(object({
    path_pattern = string
    lambda_arn   = string
    event_type   = optional(string, "viewer-request")
    include_body = optional(bool, false)
  }))
  default = []
}

variable "custom_origins" {
  type = list(object({
    origin_id           = string
    origin_path         = optional(string, null)
    domain_name         = string
    connection_attempts = optional(number, null)
    connection_timeout  = optional(number, null)
    custom_origin_config = object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number, null)
      origin_read_timeout      = optional(number, null)
    })
  }))
  default = []
}

variable "custom_ordered_cache_behaviours" {
  type = list(object({
    path_pattern     = string
    target_origin_id = string

    allowed_methods = list(string)
    cached_methods  = list(string)

    cache_policy_id            = string
    origin_request_policy_id   = optional(string, null)
    response_headers_policy_id = optional(string, null)

    compress = optional(bool, false)

    viewer_protocol_policy = string

    function_associations = optional(
      list(
        object({
          event_type   = string
          function_arn = string
        })
      ),
      []
    )

    lambda_function_associations = optional(
      list(
        object({
          lambda_arn   = string
          event_type   = optional(string, "viewer-request")
          include_body = optional(bool, false)
        }),
      ),
      []
    )
  }))
  default = []
}

variable "s3_bucket_ordered_cache_behaviours" {
  type = list(object({
    path_pattern = string

    allowed_methods = list(string)
    cached_methods  = list(string)

    cache_policy_id = string

    compress = optional(bool, false)

    viewer_protocol_policy = string

    function_associations = optional(
      list(
        object({
          event_type   = string
          function_arn = string
        })
      ),
      []
    )

    lambda_function_associations = optional(
      list(
        object({
          lambda_arn   = string
          event_type   = optional(string, "viewer-request")
          include_body = optional(bool, false)
        }),
      ),
      []
    )
  }))
  default = []
}

variable "web_acl_arn" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
}
