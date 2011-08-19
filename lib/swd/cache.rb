module SWD
  class Cache
    def self.fetch(cache_key, options = {})
      yield
    end
  end
  self.cache = Cache
end