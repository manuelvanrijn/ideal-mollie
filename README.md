
# Ideal Mollie (ideal-mollie) ![Build Status](https://secure.travis-ci.org/technoweenie/faraday.png?branch=master) ![Dependency Status](https://gemnasium.com/manuelvanrijn/ideal-mollie.png?travis)

A simple Ruby implementation for handling iDeal transactions with the [Mollie API](https://www.mollie.nl/support/documentatie/betaaldiensten/ideal/).

Here you can find the [Documentation](http://rubydoc.info/github/manuelvanrijn/ideal-mollie/master/frames)

## Getting started

### Install

To install the gem you could execute

```
sudo gem install ideal-mollie
```

Or you could add the gem into your `Gemfile`.

```
gem 'ideal-mollie'
```

Finally, if you don’t dig any of that gemming that’s so popular nowadays, you can install it as a plugin;

```
cd vendor/plugins
git clone --depth 1 git://github.com/manuelvanrijn/ideal-mollie.git ideal-mollie
```

### Configuration

Add the following config parameters to your environment config file

```
config.ideal_mollie.partner_id = 123456
config.ideal_mollie.report_url = "http://example.org/report"
config.ideal_mollie.return_url = "http://example.org/return"
config.ideal_mollie.test_mode = false
```

### Example Controller

TODO

## Changelog

A details overview could be found in the [CHANGELOG](https://github.com/manuelvanrijn/ideal-mollie/blob/master/CHANGELOG.md).

## Copyright

Copyright © 2012 Manuel van Rijn. See [LICENSE](https://github.com/manuelvanrijn/ideal-mollie/blob/master/LICENSE.md) for further details.
