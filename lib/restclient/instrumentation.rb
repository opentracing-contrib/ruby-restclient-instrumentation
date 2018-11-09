require "opentracing"
require "restclient"
require "restclient/instrumentation/version"

module RestClient
  module Instrumentation
    class << self

      attr_accessor :tracer, :propagate_spans

      def instrument(tracer: OpenTracing.global_tracer, propagate_spans: true)
        @tracer = tracer
        @propagate_spans = propagate_spans

        patch_request
        patch_transmit if propagate_spans
      end

      def patch_request

        ::RestClient::Request.class_eval do
          alias_method :execute_original, :execute

          def execute(& block)
            tags = {
              'span.kind' => 'client',
              'http.method' => method,
            }

            result = nil
            ::RestClient::Instrumentation.tracer.start_active_span("#{method} #{url}") do |scope|

              @span_context = scope.span.context if ::RestClient::Instrumentation.propagate_span?

              result = execute_original(& block)
            end

            result
          end # execute
        end # module_eval
      end # patch_request

      def patch_transmit
        ::RestClient::Request.class_eval do

          alias_method :transmit_original, :transmit

          def transmit(uri, req, payload, &block)
            OpenTracing.inject(@span_context, OpenTracing::FORMAT_RACK, req) if @span_context

            transmit_original(uri, req, payload, &block)
          end # transmit
        end # class_eval
      end # patch_transmit

      def propagate_span?
        @propagate_spans
      end
    end # class << self
  end # module Instrumentation
end # module RestClient
