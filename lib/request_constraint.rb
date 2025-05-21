class RequestConstraint
  WHITELISTED_IPS = []
  MAX_ALLOWED_REQUESTS_IN_A_MINUTE = 10

  def self.matches?(request)
    return true if WHITELISTED_IPS.include?(request.remote_ip)

    request_count_in_last_minute = Request.where(ip: request.remote_ip, created_at: 1.minutes.ago..).count
    redirect('/404.html') if request_count_in_last_minute >= MAX_ALLOWED_REQUESTS_IN_A_MINUTE
    true
  end
end
