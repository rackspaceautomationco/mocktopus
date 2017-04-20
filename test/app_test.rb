# encoding: utf-8
require 'test_helper'

class AppTest < Mocktopus::Test

  def setup

  end

  def app
    Sinatra::Application
  end

   def test_inputs_nothing_raised
    body = {
        'foo' => 'bar'
      }
    input_object = create_input('/v0/bar', 'GET', nil, JSON.pretty_generate(body), 200, nil, "")

    response = post '/mocktopus/inputs/test_inputs_nothing_raised', JSON.pretty_generate(input_object)
    assert_equal(200, response.status)
  end

  def test_bad_input_returns_400
    post '/mocktopus/inputs/test_bad_input_returns_400', {}, {}
    assert_equal 400, last_response.status
  end

  def test_all_inputs
    input1 = create_input('/v0/test_all_inputs_foo', 'GET', nil, nil, 200, nil, "")
    post '/mocktopus/inputs/test_all_inputs_foo', JSON.pretty_generate(input1)

    input2 = create_input('/v0/test_all_inputs_bar', 'GET', nil, nil, 200, nil, "")
    post '/mocktopus/inputs/test_all_inputs_bar', JSON.pretty_generate(input2)

    inputs_response = get '/mocktopus/inputs'
    json = JSON.parse(inputs_response.body)
    refute_nil json['test_all_inputs_foo']
    refute_nil json['test_all_inputs_bar']
  end

  def test_match_get
    response_body_hash = {
      "key1" => "value1",
      "key2" => "value2"
    }
    input1 = create_input('/v0/test_match_get1?wsdl', 'GET', { "host"=>"example.org", "cookie"=>"" }, nil, 200, nil, response_body_hash)
    post '/mocktopus/inputs/test_match_get1', JSON.pretty_generate(input1)

    response = get '/v0/test_match_get1?wsdl'
    assert_equal(200, response.status)
    assert_equal(response_body_hash, JSON.parse(response.body))
  end

  def test_match_post
    post_body_hash = {
      "name" => "John",
      "email" => "john@127.0.0.1"
    }
    response_body_hash = {
      "response" => "ok!"
    }
    input1 = create_input('/v0/test_match_post1', 'POST', { "host"=>"example.org", "cookie"=>"" }, post_body_hash, 202, nil, response_body_hash)
    post '/mocktopus/inputs/test_match_post1', input1.to_json

    response = post '/v0/test_match_post1', post_body_hash.to_json
    assert_equal(202, response.status)
    assert_equal(response_body_hash, JSON.parse(response.body))
  end

  def test_input_by_name
    input1 = create_input('/v0/test_input_by_name_foo', 'GET', nil, "", 200, nil, "")
    post '/mocktopus/inputs/test_input_by_name_foo', input1.to_json

    input2 = create_input('/v0/test_input_by_name_bar', 'GET', nil, "", 200, nil, "")
    post '/mocktopus/inputs/test_input_by_name_bar', input2.to_json

    input_by_name_response = get '/mocktopus/inputs/test_input_by_name_foo'
    json = JSON.parse(input_by_name_response.body)
    refute_nil json
    assert_equal(input1, json)
    assert (json != input2)
  end

  def test_delete_all
    input1 = create_input('/v0/test_delete_all_foo', 'GET', nil, nil, 200, nil, "")
    post '/mocktopus/inputs/test_delete_all_foo', JSON.pretty_generate(input1)

    delete '/mocktopus/inputs'

    inputs_response = get'/mocktopus/inputs'
    json = JSON.parse(inputs_response.body)
    assert_equal(0, json.size())
  end

  def test_delete_by_name
    input1 = create_input('/v0/test_delete_by_name_foo', 'GET', nil, "", 200, nil, "")
    post '/mocktopus/inputs/test_delete_by_name_foo', JSON.pretty_generate(input1)

    input2 = create_input('/v0/test_delete_by_name_bar', 'GET', nil, "", 200, nil, "")
    post '/mocktopus/inputs/test_delete_by_name_bar', JSON.pretty_generate(input2)

    delete '/mocktopus/inputs/test_delete_by_name_foo'

    inputs_response = get '/mocktopus/inputs/test_delete_by_name_bar'
    json = JSON.parse(inputs_response.body)
    refute_nil json
    assert_equal(input2, json)
    assert (json != input1)
  end

  def test_not_found_matching_input_found
    input1 = create_input('/test_not_found_matching_input_found/1', 'POST', { "host" => "example.org", "cookie" => "" }, JSON.pretty_generate({ "foo" => "bar" }), 200, { "bar" => "foo" }, JSON.pretty_generate({ "body" => "foobar" }))
    post '/mocktopus/inputs/test_not_found_matching_input_found', JSON.pretty_generate(input1)

    response = post '/test_not_found_matching_input_found/1', JSON.pretty_generate({"foo" => "bar"})

    assert_equal(200, response.status)
  end

  def test_mock_api_calls
    uri = '/test_mock_api_calls/1'
    verb = 'POST'
    code = 200
    body = {
      "key1" => "value_one",
      "key2" => "value_two"
    }
    header 'content-type', 'application/json'
    input = create_input(uri, verb, {}, body, code, {}, '')
    post "/mocktopus/inputs/test_mock_api_calls", JSON.pretty_generate(input)

    post uri, JSON.pretty_generate(body)
    calls = get '/mocktopus/mock_api_calls'
    json = JSON.parse(calls.body)
    this_test_call = json.select{|k| k['path'] == uri }.first
    refute_nil this_test_call
    assert_equal(uri, this_test_call['path'])
    assert_equal(verb, this_test_call['verb'])
    assert_equal(body, this_test_call['body'])
  end

  def test_mock_api_calls_with_parameters
    uri = '/test_mock_api_calls_with_parameters/foo?key=(domain=getstatus.com)&start=0&pageSize=100'
    verb = 'GET'
    code = 200
    input = create_input(uri, verb, {}, '', code, {}, '')
    post "/mocktopus/inputs/#{uri}", input

    delete '/mocktopus/mock_api_calls'

    get uri
    calls = JSON.parse(get('/mocktopus/mock_api_calls').body)
    this_test_call = calls.select{|k| k['path'] == uri }.first
    refute_nil this_test_call
    assert_equal(uri, this_test_call['path'])
    assert_equal(verb, this_test_call['verb'])
  end

  def test_delete_mock_api_calls
    uri = '/test_delete_mock_api_calls/1'
    verb = 'POST'
    code = 200
    body = {
      "key1" => "value_one",
      "key2" => "value_two"
    }
    input = create_input(uri, verb, body, '', code, {}, '')
    post "/mocktopus/inputs/#{uri}", input

    post uri, JSON.pretty_generate(body)
    calls = get '/mocktopus/mock_api_calls'
    json = JSON.parse(calls.body)
    assert(0 < json.size)
    delete '/mocktopus/mock_api_calls'
    calls = get '/mocktopus/mock_api_calls'
    json = JSON.parse(calls.body)
    assert(0 == json.size)
  end

  def test_get_missing_input_returns_405
    response = get "/mocktopus/inputs/does_not_exist"
    assert_equal(405, response.status)
  end

  def test_input_sequencing
    uri = '/test_input_sequencing'
    verb = 'GET'
    code = 200
    body1 = {
      "status" => "pending"
    }
    body2 = {
      "status" => "completed"
    }

    input1 = create_input(uri, verb, {}, nil, code, {}, body1)
    input2 = create_input(uri, verb, {}, nil, code, {}, body1)
    input3 = create_input(uri, verb, {}, nil, code, {}, body2)

    post "/mocktopus/inputs/test_input_sequencing_1", JSON.pretty_generate(input1)
    post "/mocktopus/inputs/test_input_sequencing_2", JSON.pretty_generate(input2)
    post "/mocktopus/inputs/test_input_sequencing_3", JSON.pretty_generate(input3)

    response = get uri, nil
    assert_equal(body1, JSON.parse(response.body))
    response = get uri, nil
    assert_equal(body1, JSON.parse(response.body))
    response = get uri, nil
    assert_equal(body2, JSON.parse(response.body))
  end

  def test_nil_headers
    uri = '/test_nil_headers?foo=bar&email=test@test.com'
    verb = 'GET'
    code = 200
    input = create_input(uri, verb, nil, nil, code, nil, {})
    post '/mocktopus/inputs/test_nil_headers', JSON.pretty_generate(input)

    response = get uri, nil
    assert_equal(code, response.status)
  end

  def test_unicode_in_body
    uri = 'test_unicode'
    verb = 'POST'
    body =
    {
      "uri" => "¾öäëöäëü",
      "msg" => "I am the unicöde monster"
    }
    code = 200
    input = create_input(uri, verb, {}, body, code, {}, body)
    post "/mocktopus/inputs/test_unicode_in_body", JSON.pretty_generate(input)

    response = get "/mocktopus/inputs/test_unicode_in_body"
    assert_equal(body, JSON.parse(JSON.parse(response.body)['body']))
  end

  def test_uri_encoding
    uri = 'test_unicode'
    verb = 'POST'
    body =
    {
      "uri" => 'https://web.archive.org/web/20060204114947/http://www.googles.com/index_noflash.html'
    }
    code = 200
    input = create_input(uri, verb, {}, body, code, {}, body)
    post "/mocktopus/inputs/test_uri_encoding", JSON.pretty_generate(input)

    response = get "/mocktopus/inputs/test_uri_encoding"
    assert_equal(body, JSON.parse(JSON.parse(response.body)['body']))
  end

  def test_failed_match_returns_json
    random_uri = "/#{SecureRandom.uuid}"
    get random_uri
    assert_equal 428, last_response.status
    assert_equal random_uri, JSON.parse(last_response.body)['call']['path']
  end

  def test_mock_api_calls_unmatched
    uri = '/test_unmatched_mock_api_calls/1'
    verb = 'POST'
    code = 200
    body = {
      "key1" => "value_one",
      "key2" => "value_two"
    }
    input = create_input(uri, verb, {}, body, code, {}, '')
    header 'content-type', 'application/json'
    post "/mocktopus/inputs/test_unmatched_mock_api_calls", JSON.pretty_generate(input)

    post uri, JSON.pretty_generate(body)
    put uri, JSON.pretty_generate(body)
    calls = get '/mocktopus/mock_api_calls?unmatched=true'
    json = JSON.parse(calls.body)
    this_test_call = json.select{|k| k['path'] == uri }.first
    refute_nil this_test_call
    assert_equal(uri, this_test_call['path'])
    assert_equal("PUT", this_test_call['verb'])
    assert_equal(body, this_test_call['body'])
  end

  private
  def create_input(uri, verb, headers, body, response_code, response_headers, response_body)
    input = {}
    input['uri'] = uri
    input['headers'] = headers
    input['body'] = body
    input['verb'] = verb
    input['response'] = {
      "code" => response_code,
      "headers" => response_headers,
      "body" => response_body,
      "delay" => 0
    }
    return input
  end
end
