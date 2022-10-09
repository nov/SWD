module SWD
  class Resource
    include AttrRequired, AttrOptional
    attr_required :principal, :service, :host, :path
    attr_optional :port

    class Expired < Exception; end

    def initialize(attributes = {})
      (optional_attributes + required_attributes).each do |key|
        self.send "#{key}=", attributes[key]
      end
      @path ||= '/.well-known/simple-web-discovery'
      attr_missing!
    end

    def discover!(cache_options = {})
      SWD.cache.fetch(cache_key, cache_options) do
        handle_response do
          SWD.http_client.get endpoint.to_s
        end
      end
    end

    def endpoint
      SWD.url_builder.build [nil, host, port, path, {
        :principal => principal,
        :service => service
      }.to_query, nil]
    rescue URI::Error => e
      raise Exception.new(e.message)
    end

    private

    def handle_response
      json = yield.body.with_indifferent_access
      if redirect = json[:SWD_service_redirect]
        redirect_to redirect[:location], redirect[:expires]
      else
        to_response_object json
      end
    rescue Faraday::Error => e
      case e.response_status
      when nil
        raise Exception.new e
      when 400
        raise BadRequest.new('Bad Request', e.response_body)
      when 401
        raise Unauthorized.new('Unauthorized', e.response_body)
      when 403
        raise Forbidden.new('Forbidden', e.response_body)
      when 404
        raise NotFound.new('Not Found', e.response_body)
      else
        raise HttpError.new(e.response_status, e.response_body, e.response_body)
      end
    end

    # NOTE: overwritten in openid_connect gem.
    def to_response_object(json)
      Response.new json
    end

    def redirect_to(location, expires)
      uri = URI.parse(location)
      @host, @path, @port = uri.host, uri.path, uri.port
      raise Expired if expires && expires.to_i < Time.now.utc.to_i
      discover!
    end

    def cache_key
      sha256 = OpenSSL::Digest::SHA256.hexdigest [
        principal,
        service,
        host
      ].join(' ')
      "swd:resource:#{sha256}"
    end
  end
end
