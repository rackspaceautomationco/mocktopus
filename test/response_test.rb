require 'test_helper'

class ResponseTest < Mocktopus::Test

  def test_to_hash
    input = build_response({})
    hash  = input.to_hash

    assert_equal(hash['headers']['Content-Type'],  'application/json')
    assert_equal(hash['body'], '{}')
    assert_equal(hash['code'], 200)
  end

  def test_to_hash_extra_fields
    input = build_response({'nosuch' => 'extra'})
    hash  = input.to_hash

    assert_equal(hash['nosuch'], nil)
  end

  def test_validation

    assert_raises Mocktopus::Response::ValidationError do
      build_response({'headers' => {nil => nil}})
    end

    assert_raises Mocktopus::Response::ValidationError do
      build_response({'code' => "Not a code"})
    end
    build_response({})

  end

  def test_delay_integer
    input = build_response({'delay' => 15})
    hash = input.to_hash
    assert_equal(15, hash['delay'])
  end

  def test_delay_float
    input = build_response({'delay' => 12.54542})
    hash = input.to_hash
    assert_equal(12.54542, hash['delay'])
  end

  def test_delay_invalid
    input = build_response({'delay' => 'invalid_delay'})
    hash = input.to_hash
    assert_equal(0, hash['delay'])
  end

  def build_response(hash)
    response = Mocktopus::Response.new(
      {
        'code'  => 200,
        'headers' => {
          'Content-Type' => 'application/json'
        },
        'body' => '{}'
      }.merge(hash)
    )
    return response
  end
end
