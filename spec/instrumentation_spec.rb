require 'spec_helper'

RSpec.describe RestClient::Instrumentation do
  describe "Class Methods" do
    it { should respond_to :instrument }
  end

  let (:tracer) { OpenTracingTestTracer.build }

  before do
    RestClient::Instrumentation.instrument(tracer: tracer)
  end

  describe :instrument do
    it "patches the class's execute method" do
      expect(RestClient::Request.new(method: :get, url: "www.example.com")).to respond_to(:execute_original)
    end

    it "patches the class's transmit method" do
      expect(RestClient::Request.new(method: :get, url: "www.example.com")).to respond_to(:execute_original)
    end
  end

  describe "RestClient instrumentation" do

    # clear the tracer spans after each test
    after do
      tracer.spans.clear
    end

    it "calls the original execute method" do
      allow_any_instance_of(RestClient::Request).to receive(:execute_original).and_return("response")
      expect_any_instance_of(RestClient::Request).to receive(:execute_original)

      RestClient::Request.execute(method: :get, url: "www.example.com")
    end

    it "adds spans when execute is called" do
      allow_any_instance_of(RestClient::Request).to receive(:execute_original).and_return("response")

      RestClient::Request.execute(method: :get, url: "www.example.com")
      expect(tracer.spans.count).to be > 0
    end
  end
end
