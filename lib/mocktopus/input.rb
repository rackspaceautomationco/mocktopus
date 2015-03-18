require 'net/http'
require 'json'
require 'uri'
require 'rack'

module Mocktopus

  class Input

    class Error < Exception
    end

    class ValidationError < Error
    end

    attr_accessor :uri,
    :headers,
    :body,
    :url_parameters,
    :verb,
    :response

    def initialize(hash, response)

      uri_object = nil
      begin                                                               
        uri_object = URI.parse(hash['uri'])
      rescue URI::InvalidURIError
        begin
          uri_object = URI.parse(URI::encode(hash['uri']))
        rescue URI::InvalidURIError                                   
          raise ValidationError, "Input uri \"#{hash['uri']}\" is not a valid uri" 
        end
      end

      @uri = uri_object.path
      @url_parameters = Rack::Utils.parse_nested_query(uri_object.query)
      @headers = hash['headers']
      #need to transform body from inferred json/hash to string (if applicable)
      body = ''
      begin
        body = JSON.pretty_generate(hash['body'])
      rescue
        body = hash['body']
      end
      @body = body
      @verb = hash['verb'].upcase
      @response = response

      validate_instance_variables

      LOGGER.debug("initialized input object from hash #{hash.inspect()}")
    end

    def to_hash
      uri_with_parameters = ''
      if(@url_parameters != nil && @url_parameters.length > 0)
        @url_parameters.each do |k,v| 
          if (uri_with_parameters.empty?)
            uri_with_parameters ="#{@uri}?"
          else
            uri_with_parameters = "#{uri_with_parameters}&"
          end
          uri_with_parameters = "#{uri_with_parameters}#{k}=#{v}"
        end
      else
        uri_with_parameters = @uri
      end

      {
        'uri'  => uri_with_parameters,
        'verb' => @verb,
        'headers' => @headers,
        'body' => @body,
        'response' => @response.to_hash
      }
    end

    def to_s
      self.to_hash.to_json
    end

    private
    def validate_instance_variables

      unless @headers.nil?
        @headers.each do |key, value|
          unless String.eql? key.class and String.eql? value.class
            raise ValidationError, "\"#{key}\" => \"#{value}\" is not a valid header"
          end
        end
      end

      unless @response.nil?
        unless Mocktopus::Response.eql? @response.class
          raise ValidationError, "\"#{@response}\" is not a response object"
        end
      end

      unless %w{ OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PATCH}.include? @verb
        raise ValidationError, "\"#{@verb}\" is not a valid verb"
      end
    end

  end

end
