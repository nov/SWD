require 'json'
require 'logger'
require 'openssl'
require 'active_support'
require 'active_support/core_ext'
require 'faraday'
require 'faraday/follow_redirects'
require 'attr_required'
require 'attr_optional'

module SWD
  VERSION = ::File.read(
    ::File.join(::File.dirname(__FILE__), '../VERSION')
  ).strip

  def self.cache=(cache)
    @@cache = cache
  end
  def self.cache
    @@cache
  end

  def self.discover!(attributes = {})
    Resource.new(attributes).discover!(attributes[:cache])
  end

  def self.logger
    @@logger
  end
  def self.logger=(logger)
    @@logger = logger
  end
  self.logger = ::Logger.new(STDOUT)
  self.logger.progname = 'SWD'

  def self.debugging?
    @@debugging
  end
  def self.debugging=(boolean)
    @@debugging = boolean
  end
  def self.debug!
    self.debugging = true
  end
  def self.debug(&block)
    original = self.debugging?
    self.debugging = true
    yield
  ensure
    self.debugging = original
  end
  self.debugging = false

  def self.http_client
    Faraday.new(headers: {user_agent: "SWD #{VERSION}"}) do |faraday|
      faraday.response :raise_error
      faraday.response :json
      faraday.response :follow_redirects
      faraday.response :logger, SWD.logger if debugging?
      faraday.adapter Faraday.default_adapter
      http_config.try(:call, faraday)
    end
  end
  def self.http_config(&block)
    @@http_config ||= block
  end

  def self.url_builder
    @@url_builder ||= URI::HTTPS
  end
  def self.url_builder=(builder)
    @@url_builder = builder
  end
end

require 'swd/cache'
require 'swd/exception'
require 'swd/resource'
require 'swd/response'

SWD.cache = SWD::Cache.new
