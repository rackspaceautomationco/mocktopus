require 'test_helper'

class InputContainerTest < Mocktopus::Test

  def test_initialize_not_nil
    container = Mocktopus::InputContainer.new
    refute_nil container
  end

  def test_all_returns_zero_on_init
    container = Mocktopus::InputContainer.new
    all_inputs = container.all()
    assert_equal(0, all_inputs.size())
  end

  def test_all_returns_count_after_add
    container = Mocktopus::InputContainer.new
    container.add("hash1", {})
    container.add("hash2", {})
    all_inputs = container.all()
    assert_equal(2, all_inputs.size())
  end

  def test_get_by_returns_existing_input
    container = Mocktopus::InputContainer.new
    container.add("hash1", {})
    hash1 = container.get_by("hash1")
    refute_nil hash1
  end

  def test_get_by_returns_nil_for_missing_input
    container = Mocktopus::InputContainer.new
    container.add("hash1", {})
    hash2 = container.get_by("hash2")
    assert_nil(hash2)
  end

  def test_delete_all_returns_empty_hash
    container = Mocktopus::InputContainer.new
    container.add("hash1", {})
    container.add("hash2", {})
    container.delete_all()
    all_after_delete = container.all()
    assert_equal(0, all_after_delete.size())
  end

  def test_delete_by_deletes_input
    container = Mocktopus::InputContainer.new
    container.add("hash1", {})
    container.add("hash2", {})
    container.delete_by("hash2")
    all = container.all()
    assert_equal(1, all.size())
    hash1 = container.get_by("hash1")
    refute_nil hash1
  end

  def test_delete_by_missing_input_does_nothing
    container = Mocktopus::InputContainer.new
    container.add("hash1", {})
    container.delete_by("hash2")
    all = container.all()
    assert_equal(1, all.size())
    hash1 = container.get_by("hash1")
    refute_nil hash1
  end

  def test_single_match_returns_match
    response = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
          "foo" => "baz"
        }
      })

    input = Mocktopus::Input.new({
      "uri" => "/v0/test_single_match_returns_match",
      "verb" => "POST",
      "headers" => {},
      "body"  => {
        "foo" => "bar"
      }
    }, response)

    container = Mocktopus::InputContainer.new
    container.add("input1", input)
    match_result = container.match("/v0/test_single_match_returns_match", "POST", {}, JSON.pretty_generate({"foo" => "bar"}), {})
    refute_nil match_result
    assert_equal(response, match_result.response)
  end

  def test_single_match_returns_match_encoded
    response = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
          "key" => "test_single_match_returns_match_encoded"
        }
      })

    input = Mocktopus::Input.new({
      "uri" => "/v0/test_single_match_returns_match_encoded/(key%3Dvalue)",
      "verb" => "POST",
      "headers" => {},
      "body"  => {
        "key" => "test_single_match_returns_match_encoded"
      }
    }, response)

    container = Mocktopus::InputContainer.new
    container.add("input1", input)
    match_result = container.match("/v0/test_single_match_returns_match_encoded/(key=value)", "POST", {}, JSON.pretty_generate({"key" => "test_single_match_returns_match_encoded"}), {})
    refute_nil match_result
    assert_equal(response, match_result.response)
  end

  def test_headers_match_returns_single_result_for_dashes
        response = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
          "key" => "test_headers_match_returns_single_result_for_dashes"
        }
      })

    input = Mocktopus::Input.new({
      "uri" => "/v0/test_headers_match_returns_single_result_for_dashes",
      "verb" => "GET",
      "headers" => { 'g-sub-me' => 'fizz'},
      'body' => {}
    }, response)

    container = Mocktopus::InputContainer.new
    container.add("input1", input)
    match_result = container.match("/v0/test_headers_match_returns_single_result_for_dashes", "GET", {'g_sub_me' => 'fizz'}, {}, {})
    refute_nil match_result
    assert_equal(response, match_result.response)
  end

  def test_headers_different_value_no_result_for_dashes
        response = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
          "key" => "test_headers_different_value_no_result_for_dashes"
        }
      })

    input = Mocktopus::Input.new({
      "uri" => "/v0/test_headers_different_value_no_result_for_dashes",
      "verb" => "GET",
      "headers" => { 'g-sub-mez' => 'fizz'},
      'body' => {}
    }, response)

    container = Mocktopus::InputContainer.new
    container.add("input1", input)
    match_result = container.match("/v0/test_headers_different_value_no_result_for_dashes", "GET", {'g_sub_me' => 'fizz'}, {}, {})
    assert_nil match_result
  end

  def test_headers_no_match_returns_nil_result_for_dashes
        response = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
          "key" => "test_headers_no_match_returns_nil_result_for_dashes"
        }
      })

    input = Mocktopus::Input.new({
      "uri" => "/v0/test_headers_no_match_returns_nil_result_for_dashes",
      "verb" => "GET",
      "headers" => { 'g-sub-me' => 'pop'}
    }, response)

    container = Mocktopus::InputContainer.new
    container.add("input1", input)
    match_result = container.match("/v0/test_headers_no_match_returns_nil_result_for_dashes", "GET", {'g_sub_me' => 'fizz'}, nil, nil)
    assert_nil match_result
  end

  def test_single_match_no_inputs_returns_nil
    container = Mocktopus::InputContainer.new
    match_result = container.match("/v0/test_single_match_no_inputs_returns_nil", "POST", {}, JSON.pretty_generate({}), {})
    assert_nil(match_result)
  end

  def test_multiple_inputs_returns_correct_sequence
    response1 = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
          "status" => "pending"
        }
      })

    response2 = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
          "status" => "complete"
        }
      })

    input_hash = {
      "uri" => "/v0/test_multiple_inputs_returns_correct_sequence",
      "verb" => "GET",
      "headers" => {},
      "body" => nil
    }

    container = Mocktopus::InputContainer.new
    container.add("first_input", Mocktopus::Input.new(input_hash, response1))
    container.add("second_input", Mocktopus::Input.new(input_hash, response1))
    container.add("last_input", Mocktopus::Input.new(input_hash, response2))

    first_match = container.match("/v0/test_multiple_inputs_returns_correct_sequence", "GET", {}, "", {})
    assert_equal(response1, first_match.response)

    second_match = container.match("/v0/test_multiple_inputs_returns_correct_sequence", "GET", {}, "", {})
    assert_equal(response1, second_match.response)

    last_match = container.match("/v0/test_multiple_inputs_returns_correct_sequence", "GET", {}, "", {})
    assert_equal(response2, last_match.response)
  end

  def test_body_hash_order
    response = Mocktopus::Response.new({
        "code" => "200",
        "headers" => {},
        "body" => {
        }
      })

    input1 = Mocktopus::Input.new({
      "uri" => "/v1/aliases",
      "verb" => "POST",
      "headers" => {
        },
      "body"  => {
        "addresses" => ["real1@real.com", "test1@test.com"], "email" => "aliascreateoknotype@alias.com"
      }
    }, response)

    container = Mocktopus::InputContainer.new
    container.add("input1", input1)
    match_result = container.match("/v1/aliases", "POST", {},
      JSON.pretty_generate({"email" => "aliascreateoknotype@alias.com", "addresses" => ["real1@real.com", "test1@test.com"]}), {})
    # require 'pry'
    # binding.pry
    refute_nil match_result
    assert_equal(response, match_result.response)
  end

end
