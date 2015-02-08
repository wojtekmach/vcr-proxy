# VCR::Proxy

VCR::Proxy records and replays your HTTP interactions.

## Usage

```
# 1. Start a service on port 1234

# 2. Start vcr-proxy in recording mode:
$ vcr-proxy http://localhost:1234 true
# starting server on port 8080...

# Access "origin" service through VCR proxy
$ curl http://localhost:1234/?echo=foo --proxy http://localhost:8080
foo

$ curl http://localhost:1234/?echo=bar --proxy http://localhost:8080
bar

# 3. Kill "origin" server

# 4. Requests can still be served using recorded VCR cassettes, even though the "origin" is dead.

$ curl http://localhost:1234/?echo=bar --proxy http://localhost:8080
bar

# 5. Making a request that hasn't been recorded fails:
$ curl http://localhost:1234/?echo=baz --proxy http://localhost:8080
...
An HTTP request has been made that VCR does not know how to handle
...

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vcr-proxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
