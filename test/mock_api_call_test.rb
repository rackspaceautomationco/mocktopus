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

  def test_constructor_form_data
    path = ''
    verb = 'POST'
    headers = {}
    headers['content_type'] = 'application/x-www-form-urlencoded'
    expected_body = <<-EOH.sub(/\n$/, '')
from=test.user@example.com&subject=Test Email&text=﻿TEST EMAIL&html=﻿<!DOCTYPE html>\r
\r
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">\r
<head>\r
    <meta charset="utf-8" />\r
    <title></title>\r
</head>\r
<body>\r
    <p>\r
        TEST EMAIL\r
    </p>\r
</body>\r
</html>&to="TEST EMAIL" <response@example.com>&o:tag=test_template&o:testmode=yes
EOH
    body = "from%3Dtest.user%40example.com%26subject%3DTest+Email%26text%3D%EF%BB%BFTEST+EMAIL%26html%3D%EF%BB%BF%3C%21DOCTYPE+html%3E%0D%0A%0D%0A%3Chtml+lang%3D%22en%22+xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F1999%2Fxhtml%22%3E%0D%0A%3Chead%3E%0D%0A++++%3Cmeta+charset%3D%22utf-8%22+%2F%3E%0D%0A++++%3Ctitle%3E%3C%2Ftitle%3E%0D%0A%3C%2Fhead%3E%0D%0A%3Cbody%3E%0D%0A++++%3Cp%3E%0D%0A++++++++TEST+EMAIL%0D%0A++++%3C%2Fp%3E%0D%0A%3C%2Fbody%3E%0D%0A%3C%2Fhtml%3E%26to%3D%22TEST+EMAIL%22+%3Cresponse%40example.com%3E%26o%3Atag%3Dtest_template%26o%3Atestmode%3Dyes"
    call = Mocktopus::MockApiCall.new(path, verb, headers, body)
    refute_nil call
    assert_equal(path, call.path)
    assert_equal(verb, call.verb)
    assert_equal(headers, call.headers)
    assert_equal(expected_body, call.body)
  end
end
