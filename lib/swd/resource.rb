require 'digest/md5'
require 'json'
require 'httpclient'
require 'active_support/core_ext'
require 'attr_required'

module SWD
  class Resource
    include AttrRequired
    attr_required :principal, :service, :host, :path

    class ContentExpired < Exception; end

    def initialize(attributes = {})
      required_attributes.each do |key|
        self.send "#{key}=", attributes[key]
      end
      @path ||= '/.well-known/simple-web-discovery'
      @cache_options = attributes[:cache] || {}
      attr_missing!
    end

    def discover!
      SWD.cache.fetch(cache_key, @cache_options) do
        handle_response do
          HTTPClient.get endpoint.to_s
        end
      end
    end

    def endpoint
      URI::HTTPS.build [nil, host, 443, path, {
        :principal => principal,
        :service => service
      }.to_query, nil]
    end

    private

    def handle_response
      res = yield
      case res.status
      when 200
        res = JSON.parse(res.body).with_indifferent_access
        if redirect = res[:SWD_service_redirect]
          redirect_to redirect[:location], redirect[:expires]
        else
          Response.new res
        end
      when 400
        raise BadRequest.new(res)
      when 401
        raise Unauthorized.new(res)
      when 403
        raise Forbidden.new(res)
      when 404
        raise NotFound.new(res)
      else
        raise HttpError.new(res.code, res)
      end
    end

    def redirect_to(location, expires)
      uri = URI.parse(location)
      @host, @path = uri.host, uri.path
      raise ContentExpired if expires && expires.to_i < Time.now.utc.to_i
      discover!
    end

    def cache_key
      md5 = Digest::MD5.hexdigest [
        principal,
        service,
        host
      ].join(' ')
      "swd:resource:#{md5}"
    end
  end
end