require 'test_helper'

describe "VCR::Proxy" do
  let(:echo_uri) { URI("http://localhost:9999") }

  before do
    @pid = Process.spawn("rackup ./test/support/echo.ru -p 9999")
    Monitor.new(echo_uri).wait_until_ready
  end

  after do
    Process.kill("SIGINT", @pid)
  end

  it "works" do
    assert_equal "foo", Net::HTTP.get_response(echo_uri + "?echo=foo").body
    assert_equal "bar", Net::HTTP.get_response(echo_uri + "?echo=bar").body
  end
end


# https://github.com/jsl/shamrock
class Monitor
  def initialize(uri)
    @uri = URI(uri)
  end

  def start
    @pid = Process.spawn
  end

  def stop
    Process.kill(@pid)
  end

  def wait_until_ready
    wait = 0.01
    sleep(wait) until ready?
  end

  def ready?
    Net::HTTP.get_response(@uri)
    true
  rescue SystemCallError, SocketError
    false
  end
end
