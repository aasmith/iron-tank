module Fetcher
  class Base
    def initialize(details, external_id)
      @details = details
      @external_id = external_id
    end

    def fetch
      raise NotImplementedError
    end
  end
end
