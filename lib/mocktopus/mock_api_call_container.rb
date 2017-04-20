module Mocktopus

  class MockApiCallContainer
    def initialize
      @calls = []
    end

    def add(mock_api_call)
      @calls << mock_api_call
    end

    def all(unmatched_only=false)
      @calls.collect { |c|
        if (unmatched_only && c.matched) then
            nil
        else
          result = c.to_hash
          result.delete('matched')
          result
        end
      }.compact
    end

    def delete_all
      @calls = []
    end
  end
end
