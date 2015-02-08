require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end

module VCR
  module Proxy
    # Based on: https://gist.github.com/chneukirchen/32376
    class Server
      def initialize(backend_uri, record:)
        @backend_uri = backend_uri
        @record = record
      end

      def call(env)
        rackreq = Rack::Request.new(env)

        headers = Rack::Utils::HeaderHash.new
        env.each { |key, value|
          if key =~ /HTTP_(.*)/
            headers[$1] = value
          end
        }

        res = VCR.use_cassette("foo", record: record_mode) {

          Net::HTTP.start(@backend_uri.host, @backend_uri.port) { |http|
            m = rackreq.request_method
            case m
            when "GET", "HEAD", "DELETE", "OPTIONS", "TRACE"
              req = Net::HTTP.const_get(m.capitalize).new(rackreq.fullpath, headers)
            when "PUT", "POST"
              req = Net::HTTP.const_get(m.capitalize).new(rackreq.fullpath, headers)
              req.body_stream = rackreq.body
            else
              raise "method not supported: #{method}"
            end

            http.request(req)
          }

        }

        [res.code, Rack::Utils::HeaderHash.new(res.to_hash), [res.body]]
      end

      private

      def record_mode
        @record ? :new_episodes : :none
      end
    end
  end
end
