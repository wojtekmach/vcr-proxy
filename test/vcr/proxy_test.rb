require 'test_helper'
require 'shamrock'

Echo = proc { |env|
  req = Rack::Request.new(env)
  content = req.params["echo"].to_s

  [200, {'Content-Type' => 'text/plain'}, [content]]
}

describe "VCR::Proxy" do
  before do
    @echo_service = Shamrock::Service.new(Echo)
    @echo_service.start
  end

  after do
    @echo_service.stop
  end

  it "works" do
    assert_equal "foo", get_response(@echo_service.uri + "?echo=foo").body
    assert_equal "bar", get_response(@echo_service.uri + "?echo=bar").body
  end

  private

  def get_response(uri)
    Net::HTTP.get_response(uri)
  end
end
