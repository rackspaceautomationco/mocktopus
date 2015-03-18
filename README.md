[![Build Status](https://travis-ci.org/rackspaceautomationco/mocktopus.svg?branch=v0.0.1)](https://travis-ci.org/rackspaceautomationco/mocktopus) [![Coverage Status](https://coveralls.io/repos/rackspaceautomationco/mocktopus/badge.svg)](https://coveralls.io/r/rackspaceautomationco/mocktopus) [![Gem Version](https://badge.fury.io/rb/mocktopus.svg)](http://badge.fury.io/rb/mocktopus)

       . .
      -|-|-. .-,
       '-' '-`'-
                            .   .
              ,-,-. ,-. ,-. | , |- ,-. ,-. . . ,-.
              | | | | | |   |<  |  | | | | | | `-.
              ' ' ' `-' `-' ' ` `' `-' |-' `-^ `-'
                                       |
                                       '
       .....
       .
       .                     ..
      ..                   ......
      ..                  ........               .....
      ..                 ..  ..  ..             ..   .
       .                 ..........                  .
       .                  ..    ..                   .
       .                   ......             .     .
        .                  ......              .   ..
        ..                ........              ...
          ............................      ......
                      .......................    .
                    ... .........                 .
                   ..   ...........               .
                 ..    .......... ..              ..
    . ....     ..     ..  ......    ...           .
     ..       ..     ..  ..... ..      ...        .
      ..    ..      ..   .  ..  .     .  .....  ...
      ......       .     .   .  ..   .   .    ...
      .           .     .    .   .   .    .
       .         .      .    .   ..  .    .         .
        .      ..       .    ..   ..      .        .
         ......        .      .    ...           ..
                       .      .      .....   ....
                      .        .         ....
                     ..        .        ..
                     .          .       .
                    .            ... ...
                  ..
          ........

## About

The Mocktopus is a Sinatra/thin-based Web API that lets you mock your app's dependencies.  A few setup-related endpoints allow you to tell The Mocktopus how to intercept and respond to any combination of uri/method/uri/headers/body.  

Written in Ruby, The Mocktopus differs from similar tools in its lack of plugin or code-driven setups.  The Mocktopus is meant to run standalone, primed, and configured exclusively by The Mocktopus Web API.  This means that an instance of The Mocktopus can be configured on the fly and independently of your apps/code.  [Inspiration](https://www.youtube.com/watch?v=JJ4S9khZKjk).

## Usage

1.  Install The Mocktopus gem

  `$ gem install mocktopus`

2.  Start The Mocktopus (add -p {PORT} to specify a port other than default/8081)

  `$ mocktopus start`

3.  Tell The Mocktopus how to behave by [creating an input](#create-an-input)

  `POST 'http://localhost:8081/mocktopus/inputs/:name' ...`

4.  Point your app to The Mocktopus to fake dependencies or prototype new code

>The Mocktopus does not persist the mocks that have been set up, which means that if the service is restarted, any mock setups that have been created will have to be resubmitted.

## Endpoints

This section describes the endpoints that The Mocktopus provides for managing mocks as well as reviewing any calls that it receives.  

### Create an input

`POST '/mocktopus/inputs/:name'`

Creates a setup instructing The Mocktopus on how to behave for a specific call.  :name is for your use only in identifying, updating, or deleting the setup later.  A sample payload follows:

```json
{
  "uri" : "/domain/domain.com/users",
  "headers" : {
    "whitelisting_key_here" : "value"
  },
  "body" : {
    "name" : "the mocktopus",
    "email" : "the_mocktopus@the_mocktopus.com"
  },
  "verb" : "POST",
  "response" : {
    "code" : "202",
    "delay": 5000,
    "headers" : {},
    "body" : "Thanks!"
  }
}
```

> POSTing to the same :name will overwrite any existing payload at that :name with the new payload.

The uri, verb, and response properties are all required.  Within the response property, code is the only required property.

| Property | Description |
|---|---|
| uri | The path and query for the mock |
| headers | Required headers for matching.  Only the headers included will be used for matching purposes.  Any additional headers supplied by a client hitting The Mocktopus will be ignored |
| body | The request body content used for matching |
| verb | The request verb used for matching |
| response | The response sent back to the client upon a successful match |

Response Properties

| Property | Description | 
|---|---|
| code | The HTTP status code returned for the response
| delay | The amount of time in milliseconds to wait before sending the mocked response back on a successful match
| headers | A collection of headers to send back with the response |
| body | The content returned on a successful match

While The Mocktopus only accepts JSON for creating and managing mocked endpoints, it can return just about whatever you like: SOAP, XML, plain text or JSON:

```json
{
  "uri" : "/domain/domain.com/users",
  "headers" : {},
  "body" : null,
  "verb" : "GET",
  "response" : {
    "code" : "200",
    "headers" : {
      "Content-Type": "application/xml"
    },
    "body" : "<users><user><id>1</id><name>John</name></user><user><id>2</id><name>Jane</name></user></users>"
  }
}
```

#### Matching Rules

The Mocktopus matches incoming requests against the uri, headers, body, and verb provided in the mock.  In the case of headers, only the headers that are actually provided in the mock are validated.  Any additional headers provided by the client are ignored.  

Matches are **case-sensitive** when checking against the uri and body elements.  For header matching, the header key is not case-sensitive, however the test against the header value is.  

Query string parameters can be included in the uri property.  Both the keys and values are case-sensitive, and the order of the query string parameters must be the same.

>Because The Mocktopus does exact matching, with JSON in particular an empty JSON object **{}** is different from a null or empty incoming payload.  To create a mock to match against an empty payload, omit the **body** element from the mock setup or set it to null.

If The Mocktopus cannot find a match, it will return status code 428 and a text/html response describing the request it couldn't match:

```
Match not found
Unable to find a match from the following API call:
Path:
/domain/domain.com/usersaadsfad
Verb:
GET
Headers:
{"version"=>"HTTP/1.1", "host"=>"127.0.0.1:8081", "connection"=>"keep-alive", "cache_control"=>"no-cache", "accept"=>"*/*", "dnt"=>"1", "accept_encoding"=>"gzip, deflate, sdch", "accept_language"=>"en-US,en;q=0.8"}
Body:   
```

#### Response Queueing

The Mocktopus allows you to queue up multiple responses for the same match.  For example, suppose you have an external service that allows you to submit a request to create something.  This process takes awhile, so the external services helpfully provide you with a URL where you can check the status of that thing, and when it's ready, the URL will return a 201 Created.  You can simulate that polling process using response queuing.  

The process you're trying to mock might look like this:

  1. POST a request to create a thing
  2. Receive back a payload with a URL you can use to poll
  3. GET the URL you were given in step 2 until you receive back a 201 status code

With request queueing, you can set up several responses to the same request.  Each match will pop a response off of the queue until there are no more, then that response will **always** be returned for any subsequent requests.

To mock this scenario, start with a mock for the initial POST and the response that is returned.

```json
{
  "uri" : "/some-resource-collection-that-takes-forever",
  "headers" : {},
  "body" : {
    "name" : "huge-thing",
    "size" : "1000 petabytes"
  },
  "verb" : "POST",
  "response" : {
    "code" : "202",
    "headers" : {},
    "body" : {
      "statusLink": "http://mocktopusip:8081/monitor/1",
      "status": "creating"
    }
  }
}
```
With the initial POST setup, you can move to set up the monitoring calls, using the **statusLink** as set up in the body as your mocked endpoint:

```json
{
  "uri" : "/monitor/1",
  "headers" : {},
  "body" : null,
  "verb" : "GET",
  "response" : {
    "code" : "200",
    "headers" : {},
    "body" : {
      "statusLink": "http://mocktopusip:8081/monitor/1",
      "status": "Still going"
    }
  }
}
```
```json
{
  "uri" : "/monitor/1",
  "headers" : {},
  "body" : null,
  "verb" : "GET",
  "response" : {
    "code" : "200",
    "headers" : {},
    "body" : {
      "statusLink": "http://mocktopusip:8081/monitor/1",
      "status": "Yep, still going"
    }
  }
}
```
```json
{
  "uri" : "/monitor/1",
  "headers" : {},
  "body" : null,
  "verb" : "GET",
  "response" : {
    "code" : "200",
    "headers" : {},
    "body" : {
      "statusLink": "http://mocktopusip:8081/monitor/1",
      "status": "Almost there..."
    }
  }
}
```

With this, you have set up three responses for the same request match.  While The Mocktopus doesn't have a concept of returning a request for a period of time, you can set up as many responses to the same request as you want.  

Now that you have set up your request to simulate polling, you can add your final request which will be returned when a client hits the /monitor/1 resource:


```json
{
  "uri" : "/monitor/1",
  "headers" : {},
  "body" : null,
  "verb" : "GET",
  "response" : {
    "code" : "201",
    "headers" : {},
    "body" : {
      "self": "http://mocktopusip:8081/some-resource-collection-that-takes-forever/huge-thing"
    }   
  }
}
```

You could continue this mock setup by then mocking the /some-resource-collection-that-takes-forever/huge-thing endpoint with the correct payload.


It's important to note that even though these are matching against the same request, the mocks still have to be POSTed to unique endpoints within The Mocktopus, otherwise the responses would be overwritten, not queued:

- POST /mocktopus/inputs/1
- POST /mocktopus/inputs/2
- POST /mocktopus/inputs/3

### Retrieve an input

`GET '/mocktopus/inputs/[:name]' `

Retrieves a specific input by name (if specified), or a serialized list of all inputs.

### Delete input(s)

`DELETE '/mocktopus/inputs/[:name]' `

Deletes a specific input by name (if specified), or deletes all inputs.

### Get all calls received by The Mocktopus

`GET '/mocktopus/mock_api_calls' `

Retrieves a serialized list of all calls received by The Mocktopus (excluding setups).

### Delete all calls

`DELETE '/mocktopus/mock_api_calls' `

Deletes all stored calls.

## Contributing

1.  Fork/clone The Mocktopus repo
2.  Make sure tests pass by running `rake` at the root of the project
3.  Add tests for your change.  Make your change, and make sure that tests pass by running `rake` again
4.  Commit to your fork using a good commit message
5.  Push and submit a pull request

## License

Distributed under the [MIT-LICENSE](/MIT-LICENSE)
