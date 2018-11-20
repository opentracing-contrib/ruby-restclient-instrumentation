require 'spec_helper'

RSpec.describe RestClient::Instrumentation do
  describe "Class Methods" do
    it { should respond_to :instrument }
  end

  let (:tracer) { OpenTracingTestTracer.build }
  let (:url) { "http://www.example.com/" }

  before do
    OpenTracing.global_tracer = tracer
    RestClient::Instrumentation.instrument(tracer: tracer)
  end

  describe :instrument do
    it "patches the class's execute method" do
      expect(RestClient::Request.new(method: :get, url: url)).to respond_to(:execute_original)
    end

    it "patches the class's transmit method" do
      expect(RestClient::Request.new(method: :get, url: url)).to respond_to(:execute_original)
    end
  end

  describe "RestClient instrumentation" do
    let (:request) { RestClient::Request.new(method: :get, url: url) }
    let (:net_response) { Net::HTTPResponse.new(nil, 200, "message") }
    let (:response) { RestClient::Response.create("body", net_response, request)}

    # clear the tracer spans after each test
    after do
      tracer.spans.clear
    end

    it 'calls the original execute method' do
      allow_any_instance_of(RestClient::Request).to receive(:execute_original).and_return(response)
      expect_any_instance_of(RestClient::Request).to receive(:execute_original)

      response = RestClient::Request.execute(method: :get, url: url)

      expect(response.code).to eq 200
    end

    context 'when execute is called' do
      before do
        allow_any_instance_of(RestClient::Request).to receive(:execute_original).and_return(response)

        RestClient::Request.execute(method: :get, url: url)
      end

      let (:span) { tracer.spans.last }

      it 'adds a span to the tracer' do
        expect(tracer.spans.count).to eq 1
      end

      it 'adds a span.kind tag' do
        expect(span.tags.fetch('span.kind')).to eq 'client'
      end

      it 'adds a http.method tag' do
        expect(span.tags.fetch('http.method')).to eq 'get'
      end

      it 'adds a http.url tag' do
        expect(span.tags.fetch('http.url')).to eq url
      end

      it 'adds a http.status_code tag' do
        expect(span.tags.fetch('http.status_code')).to eq 200
      end
    end
  end
end
