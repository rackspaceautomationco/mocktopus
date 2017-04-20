require 'time'
require 'json'
require 'uri'

module Mocktopus

  class MockApiCall

    attr_accessor :timestamp,
      :path,
      :verb,
      :headers,
      :body,
      :matched

    def initialize(path, verb, headers, body)
      @timestamp = Time.now.utc.iso8601(10)
      @path = path
      @verb = verb
      @headers = headers
      @matched = false
      begin
        @body = if @headers.has_key?('content_type') && @headers['content_type'] == 'application/x-www-form-urlencoded'
                  URI::decode_www_form_component(body).to_s
                else
                  JSON.parse(body)
                end
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
        'body' => @body,
        'matched' => @matched
      }
    end

    def to_s
      self.to_hash.to_json
    end

  end

end
