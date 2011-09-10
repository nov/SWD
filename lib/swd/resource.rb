require 'digest/md5'
require 'json'
require 'httpclient'
require 'active_support/core_ext'
require 'attr_required'

module SWD
  class Resource
    include AttrRequired
    attr_required :principal, :service, :host, :path

    class Expired < Exception; end

    def initialize(attributes = {})
      required_attributes.each do |key|
        self.send "#{key}=", attributes[key]
      end
      @path ||= '/.well-known/simple-web-discovery'
      attr_missing!
    end

    def discover!(cache_options = {})
      SWD.cache.fetch(cache_key, cache_options) do
        handle_response do
          http_client.get_content endpoint.to_s
        end
      end
    end

    def endpoint
      URI::HTTPS.build [nil, host, 443, path, {
        :principal => principal,
        :service => service
      }.to_query, nil]
    rescue URI::Error => e
      raise Exception.new(e.message)
    end

    private

    def http_client
      _http_client_ = HTTPClient.new(
        :agent_name => "SWD (#{VERSION})"
      )
      _http_client_.request_filter << Debugger::RequestFilter.new if SWD.debugging?
      _http_client_
    end

    def handle_response
      res = JSON.parse(yield).with_indifferent_access
      if redirect = res[:SWD_service_redirect]
        redirect_to redirect[:location], redirect[:expires]
      else
        to_response_object(res)
      end
    rescue HTTPClient::BadResponseError => e
      case e.res.try(:status)
      when nil
        raise Exception.new(e.message)
      when 400
        raise BadRequest.new('Bad Request', res)
      when 401
        raise Unauthorized.new('Unauthorized', res)
      when 403
        raise Forbidden.new('Forbidden', res)
      when 404
        raise NotFound.new('Not Found', res)
      else
        raise HttpError.new(e.res.status, e.res.reason, res)
      end
    rescue JSON::ParserError, OpenSSL::SSL::SSLError, SocketError => e
      raise Exception.new(e.message)
    end

    def to_response_object(hash)
      Response.new hash
    end

    def redirect_to(location, expires)
      uri = URI.parse(location)
      @host, @path = uri.host, uri.path
      raise Expired if expires && expires.to_i < Time.now.utc.to_i
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