require 'json'

module Mocktopus

  class InputContainer

    def initialize
      @inputs = {}
    end

    def add(name, input)
      @inputs[name] = input
    end

    def get_by(name)
      @inputs[name]
    end

    def all
      @inputs
    end

    def delete_all
      @inputs = {}
    end

    def delete_by(name)
      @inputs.delete(name)
    end

    def delete_by_input(input)
      first_match = @inputs.select{|k, v| v == input}.keys.first
      self.delete_by(first_match)
    end

    def match(path, verb, headers, body, url_parameters)
      self.find_match(path, verb, headers, body, url_parameters, @inputs.values)
    end

    def find_match(path, verb, headers, body, url_parameters, inputs)
      result = nil
      matches = inputs.select{|v| URI.decode(v.uri).eql?(URI.decode(path)) && 
                                                  headers_match?(headers, v.headers) && 
                                                  bodies_match?(v.body, body) && 
                                                  v.verb.eql?(verb) && 
                                                  v.url_parameters.eql?(url_parameters) }
      case matches.size
        when 0
          result = nil
        when 1
          result = matches.first
        else
          result = pop_first_input(matches)
      end
      return result
    end

    private
    def headers_match?(input_headers, match_headers)
      match = true
      if (match_headers != nil)
        match_headers.each do |k,v|
          if(input_headers[k.downcase.gsub("-", "_")].nil?)
            match = false
          elsif !input_headers[k.downcase.gsub("-", "_")].eql? v
            match = false
          end
        end
      end
      return match
    end

    def bodies_match?(input_body, match_body)
      match = false
      if (input_body.eql? match_body)
        match = true
      elsif (input_body.to_s.gsub(/\s+/, "").hash.eql?(match_body.to_s.gsub(/\s+/, "").hash))
        match = true
      end
      return match
    end

    def pop_first_input(matches)
      result = matches.first
      self.delete_by_input(result)
      return result
    end
  end

end
