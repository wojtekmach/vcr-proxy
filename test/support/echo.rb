Echo = proc { |env|
  req = Rack::Request.new(env)
  content = req.params["echo"].to_s

  [200, {'Content-Type' => 'text/plain', 'Content-Length' => content.size.to_s}, [content]]
}
