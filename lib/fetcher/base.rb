module Fetcher
  class Base
    def initialize(details, external_id = nil)
      @details = details
      @external_id = external_id
    end

    def fetch
      raise NotImplementedError
    end

    def list
      raise NotImplementedError
    end
  end
end
