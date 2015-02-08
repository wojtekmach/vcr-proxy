require 'test_helper'
require 'shamrock'
require 'vcr/proxy'
require './test/support/echo'

describe "VCR::Proxy" do
  before do
    @echo_service = Shamrock::Service.new(Echo, port: 9999)
    @echo_service.start

    @proxy_service = Shamrock::Service.new(VCR::Proxy::Server.new(@echo_service.uri, record: true))
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

  it "replays recorded HTTP interactions" do
    assert_equal "foo", get_response(@echo_service.uri + "?echo=foo").body

    @echo_service.stop
    @proxy_service.stop
    @proxy_service = Shamrock::Service.new(VCR::Proxy::Server.new(@echo_service.uri, record: false))
    @proxy_service.start

    assert_equal "foo", get_response(@echo_service.uri + "?echo=foo").body
  end

  it "fails when HTTP interaction wasn't recorded" do
    @echo_service.stop
    @proxy_service.stop
    @proxy_service = Shamrock::Service.new(VCR::Proxy::Server.new(@echo_service.uri, record: false))
    @proxy_service.start

    assert_match "An HTTP request has been made that VCR does not know how to handle", get_response(@echo_service.uri + "?echo=baz").body
  end

  private

  def get_response(uri)
    proxy_uri = @proxy_service.uri
    Net::HTTP.new(uri.host, uri.port, proxy_uri.host, proxy_uri.port).start { |http|
      http.get uri
    }
  end
end
