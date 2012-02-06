require 'logger'

module SWD
  VERSION = ::File.read(
    ::File.join(::File.dirname(__FILE__), '../VERSION')
  )

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
    _http_client_ = HTTPClient.new(
      :agent_name => "SWD (#{VERSION})"
    )
    _http_client_.request_filter << Debugger::RequestFilter.new if debugging?
    http_config.try(:call, _http_client_)
    _http_client_
  end
  def self.http_config(&block)
    @@http_config ||= block
  end
end

require 'swd/cache'
require 'swd/exception'
require 'swd/resource'
require 'swd/response'
require 'swd/debugger'

SWD.cache = SWD::Cache.new