require 'test_helper'
require 'shamrock'
require 'vcr/proxy'

Echo = proc { |env|
  req = Rack::Request.new(env)
  content = req.params["echo"].to_s

  [200, {'Content-Type' => 'text/plain'}, [content]]
}

describe "VCR::Proxy" do
  before do
    @echo_service = Shamrock::Service.new(Echo)
    @echo_service.start

    @proxy_service = Shamrock::Service.new(VCR::Proxy::Server.new(@echo_service.uri))
    @proxy_service.start
  end

  after do
    @echo_service.stop
    @proxy_service.stop
  end

  it "works" do
    assert_equal "foo", get_response(@echo_service.uri + "?echo=foo").body
    assert_equal "bar", get_response(@echo_service.uri + "?echo=bar").body
  end

  private

  def get_response(uri)
    proxy_uri = @proxy_service.uri
    Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port).start { |http|
      http.get uri
    }
  end
end
