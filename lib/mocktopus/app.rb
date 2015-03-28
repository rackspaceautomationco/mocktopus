require_relative '../../ascii.rb'

require 'sinatra'

$logger.info 'initialized mocktopus app'
$input_container = Mocktopus::InputContainer.new
$mock_api_call_container = Mocktopus::MockApiCallContainer.new

error_example = {
  "uri" => "/domain/domain.com/users",
  "headers" => {
    "whitelisting_key_here" => "value"
  },
  "body" => {
    "name" => "the mocktopus",
    "email" => "the_mocktopus@the_mocktopus.com"
  },
  "verb" => "POST",
  "response" => {
    "code" => "202",
    "delay"=> 5000,
    "headers" => {},
    "body" => "Thanks!"
  }
}

post '/mocktopus/inputs/:name' do
  $logger.info("received new input named #{params[:name]}")
  begin
    body = JSON.parse(request.body.read().to_s)
  rescue
    status 400
    content_type :json
    error_hash = { 'message' => 'inputs must be created with a valid json descripiton', 'example' => error_example }
    body error_hash.to_json
    return
  end
  $logger.debug("body: #{body.inspect()}")

  $logger.debug("creating response object from #{body['response']}")
  response = Mocktopus::Response.new(body['response'])

  $logger.debug("creating input object from #{body.inspect}, #{response.inspect}")
  input = Mocktopus::Input.new(body, response)

  $logger.info("added input #{params[:name]} successfully")
  $input_container.add(params[:name], input)
end

get '/mocktopus/inputs' do
  $logger.info("all inputs requested")
  all_inputs = $input_container.all()
  $logger.debug("found #{all_inputs.size()} inputs")
  return_inputs = {}
  all_inputs.each do |k,v|
    return_inputs[k] = v.to_hash
  end
  content_type :json
  return_inputs.to_json
end

get '/mocktopus/inputs/:name' do
  $logger.info("retrieving input by name #{params[:name]}")
  input = $input_container.get_by(params[:name])
  if (input != nil)
    input.to_hash.to_json
  else
    status 405
    body "input not found"
  end
end

get '/mocktopus/mock_api_calls' do
  content_type :json
  status 200
  body $mock_api_call_container.all.to_json
end

delete '/mocktopus/mock_api_calls' do
  $mock_api_call_container.delete_all
  status 204
end

delete '/mocktopus/inputs' do
  $logger.info("deleting all inputs")
  $input_container.delete_all()
end

delete '/mocktopus/inputs/:name' do
  $logger.info("deleting input by name #{params[:name]}")
  $input_container.delete_by(params[:name])
end

# # # catch all for 404s
not_found do
  path = request.path
  verb = request.request_method
  request_headers = env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
  unless(verb.downcase == "get" || verb.downcase == "delete")
    request_headers.merge!({ "content_type" => request.content_type})
  end
  body = request.body.read.to_s
  log_path = path
  unless (request.env['rack.request.query_hash'].nil? || request.env['rack.request.query_hash'].empty?)
    log_path += '?'
    request.env['rack.request.query_hash'].keys.each do |k|
      log_path += k
      log_path += '='
      log_path += request.env['rack.request.query_hash'][k]
      log_path += '&' unless k == request.env['rack.request.query_hash'].keys.last      
    end
  end

  $mock_api_call_container.add(Mocktopus::MockApiCall.new(log_path, verb, request_headers, body))

  $logger.info("not_found catch all invoked")
  start_time = Time.now.to_f
  $logger.debug("looking for a match with path #{request.fullpath}, verb #{verb}, headers #{request_headers}, body #{body}")
  match = $input_container.match(path, verb, request_headers, body, request.env['rack.request.query_hash'])
  $logger.debug("match lookup complete")
  if (match.nil?)
    $logger.info("match not found.  sending 428")
    status 428
    content_type :json
    body_detail = { 
      'message' => 'match not found',
      'call' => {
        'path' => request.fullpath,
        'verb' => verb,
        'headers' => request_headers,
        'body' => body
      }
    }
    body body_detail.to_json
  else
    $logger.info("match found #{match.inspect}")
    sleep(match.response.delay/1000)
    status match.response.code
    headers match.response.headers
    body match.response.body
  end
  end_time = Time.now.to_f
  $logger.info("not_found catch all completed in #{((end_time - start_time) * 1000)} milliseconds")
end
