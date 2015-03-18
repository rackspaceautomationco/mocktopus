module Mocktopus

  class MockApiCallContainer
    def initialize
      @calls = []
    end

    def add(mock_api_call)
      @calls << mock_api_call
    end

    def all
      @calls.collect(&:to_hash)
    end

    def delete_all
      @calls = []
    end
  end
end