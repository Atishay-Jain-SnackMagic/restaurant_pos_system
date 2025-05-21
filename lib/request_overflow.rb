class RequestOverflow
  WHITELISTED_IPS = [ '::1' ]
  MAX_ALLOWED_REQUESTS_IN_A_MINUTE = 10

  def self.matches?(request)
    return false if WHITELISTED_IPS.include?(request.remote_ip)

    request_count_in_last_minute = Request.where(ip: request.remote_ip, created_at: 1.minutes.ago..).count
    true if request_count_in_last_minute >= MAX_ALLOWED_REQUESTS_IN_A_MINUTE
  end
end
