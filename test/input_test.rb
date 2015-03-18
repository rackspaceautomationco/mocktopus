# encoding: utf-8
require 'test_helper'

class ResponseTest < Mocktopus::Test

  def test_to_hash
    input = build_input({})
    hash  = input.to_hash

    assert_equal( '/uri', hash['uri'])
    assert_equal( 'application/json',     hash['headers']['Content-Type'])
    assert_equal( '{}',                   hash['body'])
    assert_equal( {},                     hash['response'])
  end

  def test_to_hash_extra_fields
    input = build_input({'nosuch' => 'extra'})
    hash  = input.to_hash

    assert_equal(hash['nosuch'], nil)
  end

  def test_validate_input_errors
    assert_raises Mocktopus::Input::ValidationError do
      build_input({'uri' => '/[^\-_.!~*\'()a-zA-Z\d;\/?:@&=+$,\[\]]/
        => /[^\-_.!~*\'()a-zA-Z\d;\/?:@&=+$,\[\]]/
        irb(main):003:0> p Regexp.union([URI::Parser.new.regexp[:UNSAFE],\'~\',\'@\'])
        /(?-mix:[^\-_.!~*\'()a-zA-Z\d;\/?:@&=+$,\[\]])|~|@/
        => /(?-mix:[^\-_.!~*\'()a-zA-Z\d;\/?:@&'})
    end

    assert_raises Mocktopus::Input::ValidationError do
      build_input({'uri' => 'irb(main):005:0*'})
    end

    assert_raises Mocktopus::Input::ValidationError do
      build_input({'headers' => {nil => nil}})
    end

    build_input({'body' => nil})

    assert_raises Mocktopus::Input::ValidationError do
      build_input({}, "Not a response object")
    end

    assert_raises Mocktopus::Input::ValidationError do
      build_input({'verb' => SecureRandom.uuid})
    end

    build_input({}, nil)
  end

  def test_flexible_uris
    assert_equal(build_input({'uri' => '%C3%B6%C3%BF%C3%A0%C3%A1%C3%A4'}).to_hash, build_input({'uri' => 'öÿàáä'}).to_hash)
  end

  def test_to_hash_returns_properties_with_one_param
    hash = {
      'uri' => '/test?parameter_one=foo',
      'headers' => {
        'Content-Type' => 'appilcation/json'
      },
      'body' => {
        'body_one' => 'uno',
        'body_two' => {
          'nested' => 'value'
        }
      },
      'verb' => 'POST'
    }
    input = Mocktopus::Input.new(hash, response_with_empty_hash())

    hashed_input = input.to_hash
    assert_equal(hash['uri'], hashed_input['uri'])
    assert_equal(hash['headers'], hashed_input['headers'])
    assert_equal(JSON.pretty_generate(hash['body']), hashed_input['body'])
    assert_equal(hash['verb'], hashed_input['verb'])
  end

  def test_to_hash_returns_properties_with_no_params
    hash = {
      'uri' => '/test',
      'headers' => {
        'Content-Type' => 'appilcation/json'
      },
      'body' => {
        'body_one' => 'uno',
        'body_two' => {
          'nested' => 'value'
        }
      },
      'verb' => 'POST'
    }
    input = Mocktopus::Input.new(hash, response_with_empty_hash())

    hashed_input = input.to_hash
    assert_equal(hash['uri'], hashed_input['uri'])
    assert_equal(hash['headers'], hashed_input['headers'])
    assert_equal(JSON.pretty_generate(hash['body']), hashed_input['body'])
    assert_equal(hash['verb'], hashed_input['verb'])
  end

  def test_to_hash_returns_properties_with_two_params
    hash = {
      'uri' => '/test?parameter_one=foo&parameter_two=bar',
      'headers' => {
        'Content-Type' => 'appilcation/json'
      },
      'body' => {
        'body_one' => 'uno',
        'body_two' => {
          'nested' => 'value'
        }
      },
      'verb' => 'POST'
    }
    input = Mocktopus::Input.new(hash, response_with_empty_hash())

    hashed_input = input.to_hash
    assert_equal(hash['uri'], hashed_input['uri'])
    assert_equal(hash['headers'], hashed_input['headers'])
    assert_equal(JSON.pretty_generate(hash['body']), hashed_input['body'])
    assert_equal(hash['verb'], hashed_input['verb'])
  end

  def test_to_s
    hash = {
      'uri' => '/test/to/s',
      'verb' => 'GET'
    }
    input = Mocktopus::Input.new(hash, response_with_empty_hash())
    s = input.to_s
    assert_equal 'String', s.class.name
    
  end

  private

  def build_input(hash = {}, response = response_with_empty_hash())
    input = Mocktopus::Input.new(
      {
        'uri'  => 'http://localhost/uri',
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'body' => '{}',
        'verb' => 'post'
      }.merge(hash),
      response
    )
    return input
  end

  def response_with_empty_hash
    response = Mocktopus::Response.new({
      'code' => 200,
      'headers' => nil,
      'body' => nil
    })

    def response.to_hash
      {}
    end
    return response
  end
end