module SWD
  def self.cache=(cache)
    @@cache = cache
  end
  def self.cache
    @@cache
  end
  def self.discover!(attributes = {})
    Resource.new(attributes).discover!(attributes[:cache])
  end
end

require 'swd/cache'
require 'swd/exception'
require 'swd/resource'
require 'swd/response'

# NOTE: Default Cache doesn't cache anything.
SWD.cache = SWD::Cache.new