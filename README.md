# Restclient::Instrumentation

This gem provides instrumentation for RestClient requests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'restclient-instrumentation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install restclient-instrumentation

## Usage

To enable the instrumentation and patch RestClient:

```ruby
require 'restclient/instrumentation'

RestClient::Instrumentation.instrument
```

`instrument` takes two optional parameters:
- `tracer`: set an OpenTracing tracer to use.
  Defaults to `OpenTracing.global_tracer`.
- `propagate_spans`: Enable propagating spans through request headers.
  Defaults to `true`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/signalfx/ruby-restclient-instrumentation.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
