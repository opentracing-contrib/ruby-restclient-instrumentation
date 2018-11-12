require 'jaeger/client'
require 'jaeger/client/http_sender'
require 'rest-client'
require 'restclient/instrumentation'

# set up the exporter
ingest_url = "http://localhost:14268/api/traces"
service_name = "restclient-test"
headers = { }
encoder = Jaeger::Client::Encoders::ThriftEncoder.new(service_name: service_name)
http_sender = Jaeger::Client::HttpSender.new(url: ingest_url, headers: headers, encoder: encoder)
OpenTracing.global_tracer = Jaeger::Client.build(service_name: service_name, sender: http_sender)

# set up the instrumentation
RestClient::Instrumentation.instrument

# assumes something is listening at this address
RestClient.get "http://localhost:4567/"

begin
  RestClient.get "http://localhost:4567/nonexistent"
rescue => error
  puts error
end

# wait for spans to send
sleep(10)
