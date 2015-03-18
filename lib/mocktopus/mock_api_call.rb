require 'time'
require 'json'

module Mocktopus

  class MockApiCall

    attr_accessor :timestamp,
      :path,
      :verb,
      :headers,
      :body

    def initialize(path, verb, headers, body)
      @timestamp = Time.now.utc.iso8601(10)
      @path = path
      @verb = verb
      @headers = headers
      begin
        @body = JSON.parse(body)
      rescue
        @body = body
      end
    end

    def to_hash
      {
        'timestamp' => @timestamp,
        'path' => @path,
        'verb' => @verb,
        'headers' => @headers,
        'body' => @body
      }
    end

    def to_s
      self.to_hash.to_json
    end

  end

end
