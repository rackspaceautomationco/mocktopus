require 'json'

module Mocktopus

  class Response

    class Error < Exception
    end

    class ValidationError < Error
    end

    attr_accessor :code,
            :headers,
            :body,
            :delay

    def initialize(hash)
      LOGGER.debug("initializing response object")
      @code = hash['code']
      @headers = hash['headers']
      @body = hash['body']
      @delay = hash['delay'].to_f || 0

      begin
        @body = JSON.pretty_generate(@body)
      rescue JSON::GeneratorError
        @body = @body.to_s
      end

      validate_instance_variables()

      LOGGER.debug("initialized response object from hash #{hash.inspect()}")
    end

  def to_hash
    {
      'code' => @code,
      'headers' => @headers,
      'body' => @body,
      'delay' => @delay
    }
  end

    private
    def validate_instance_variables

      if(@code.nil? || !(@code.to_i.between?(100,599) ))
        raise ValidationError, "\"#{@code}\" is not a valid return code."
      end

      unless @headers.nil?
        @headers.each do |key, value|
          unless String.eql? key.class and String.eql? value.class
            raise ValidationError, "\"#{key}\" => \"#{value}\" is not a valid header"
          end
        end
      end

    end

  end

end
