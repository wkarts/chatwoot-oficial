class Rack::Attack
  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blocklisting and
  # safelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # https://github.com/rack/rack-attack/issues/102
  Rack::Attack.cache.store = Rack::Attack::StoreProxy::RedisProxy.new($velma)

  class Request < ::Rack::Request
    # You many need to specify a method to fetch the correct remote IP address
    # if the web server is behind a load balancer.
    def remote_ip
      @remote_ip ||= (env['action_dispatch.remote_ip'] || ip).to_s
    end

    def allowed_ip?
      allowed_ips = ['127.0.0.1', '::1']
      allowed_ips.include?(remote_ip)
    end
  end

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"

  throttle('req/ip', limit: 300, period: 5.minutes, &:ip)

  ### Prevent Brute-Force Login Attacks ###
  throttle('login/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/auth/sign_in' && req.post?
  end

  ## Prevent Brute-Force Signup Attacks ###
  throttle('accounts/ip', limit: 5, period: 1.hour) do |req|
    req.ip if req.path == '/api/v1/accounts' && req.post?
  end

  # ref: https://github.com/rack/rack-attack/issues/399
  throttle('login/email', limit: 5, period: 20.seconds) do |req|
    email = req.params['email'].presence || ActionDispatch::Request.new(req.env).params['email'].presence
    email.to_s.downcase.gsub(/\s+/, '') if req.path == '/auth/sign_in' && req.post?
  end

  throttle('reset_password/email', limit: 5, period: 1.hour) do |req|
    email = req.params['email'].presence || ActionDispatch::Request.new(req.env).params['email'].presence
    email.to_s.downcase.gsub(/\s+/, '') if req.path == '/auth/password' && req.post?
  end
end

# Log blocked events
ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |_name, _start, _finish, _request_id, payload|
  Rails.logger.info "[Rack::Attack][Blocked] remote_ip: \"#{payload[:request].remote_ip}\", path: \"#{payload[:request].path}\""
end
