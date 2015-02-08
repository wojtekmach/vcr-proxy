# Based on: https://gist.github.com/chneukirchen/32376
module VCR
  module Proxy
    class Server
      def initialize(backend_uri)
        @backend_uri = backend_uri
      end

      def call(env)
        rackreq = Rack::Request.new(env)

        headers = Rack::Utils::HeaderHash.new
        env.each { |key, value|
          if key =~ /HTTP_(.*)/
            headers[$1] = value
          end
        }

        res = Net::HTTP.start(@backend_uri.host, @backend_uri.port) { |http|
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

        [res.code, Rack::Utils::HeaderHash.new(res.to_hash), [res.body]]
      end
    end
  end
end
