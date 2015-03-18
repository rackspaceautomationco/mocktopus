require 'test_helper'

class MockApiCallTest < Mocktopus::Test

  def test_constructor
    path = '/test_constructor/1'
    verb = 'POST'
    headers = {}
    headers['header1'] = 'header1'
    headers['header2'] = 'header2'
    body = {}
    body['one'] = 1
    body['two'] = 2
    call = Mocktopus::MockApiCall.new(path, verb, headers, body)
    refute_nil call
    assert_equal(path, call.path)
    assert_equal(verb, call.verb)
    assert_equal(headers, call.headers)
    assert_equal(body, call.body)
  end

  def test_timestamp
    call = Mocktopus::MockApiCall.new('/foo/bar', 'DELETE', {}, {})
    refute_nil call.timestamp
    parsed_time = Time.iso8601(call.timestamp)
    assert_equal('Time', parsed_time.class.name)
  end

  def test_to_s
    call = Mocktopus::MockApiCall.new('/test/to/s', 'GET', {}, {})
    s = call.to_s
    assert_equal 'String', s.class.name
  end

end
