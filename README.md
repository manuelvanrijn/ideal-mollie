# Ideal Mollie (ideal-mollie) [![Gem Version](https://badge.fury.io/rb/ideal-mollie.png)][gemversion] [![Build Status](https://secure.travis-ci.org/manuelvanrijn/ideal-mollie.png?branch=master)][travis] [![Coverage Status](https://coveralls.io/repos/manuelvanrijn/ideal-mollie/badge.png?branch=coveralls)][coveralls]

[gemversion]: http://badge.fury.io/rb/ideal-mollie
[travis]: http://travis-ci.org/manuelvanrijn/ideal-mollie
[coveralls]: https://coveralls.io/r/manuelvanrijn/ideal-mollie?branch=coveralls

A simple Ruby implementation for handling iDeal transactions with the [Mollie API](https://www.mollie.nl/support/documentatie/betaaldiensten/ideal/).

Here you can find the [Documentation](http://rubydoc.info/github/manuelvanrijn/ideal-mollie/master/frames)

## Getting started

### Install

To install the gem you could execute

```ruby
sudo gem install ideal-mollie
```

Or you could add the gem into your `Gemfile`.

```ruby
gem 'ideal-mollie'
```

Finally, if you don’t dig any of that gemming that’s so popular nowadays, you can install it as a plugin;

```
cd vendor/plugins
git clone --depth 1 git://github.com/manuelvanrijn/ideal-mollie.git ideal-mollie
```

### Configuration

Add the following config parameters to your environment config file

```ruby
config.ideal_mollie.partner_id = 123456
config.ideal_mollie.report_url = "http://example.org/report"
config.ideal_mollie.return_url = "http://example.org/return"
config.ideal_mollie.test_mode = false
```

Optionally you can add a profile_key if you have multiple profile's

```ruby
config.ideal_mollie.profile_key = "123abc45"
```

## Rails Example

Below you will find a simple `TransactionController` and a view to display the bank selectbox. Note that this is just a very basic example.

### Transaction Controller

```ruby
class TransactionsController < ApplicationController
  def index
    @banks = IdealMollie.banks
  end

  def start
    # redirect to banks if there is no bank_id given
    redirect_to transaction_path if params[:bank_id].nil?
    bank_id = params[:bank_id]

    # 10,00 EUR
    request = IdealMollie.new_order(
      amount: 1000,
      description: 'some payment description',
      bank_id: bank_id
    )
    # Optionally you could override the report_url and return_url here, by doing:
    # request = IdealMollie.new_order(
    #   amount: 1000,
    #   description: 'some payment description',
    #   bank_id: bank_id,
    #   report_url: "http://url.org/report",
    #   return_url: "http://url.org/return"
    # )

    transaction_id = request.transaction_id

    # TODO: store the transaction_id like:
    # For example:
    #   my_order = MyOrderObject.find(id)
    #   my_order.transaction_id = transaction_id
    #   my_order.save

    redirect_to request.url
  end

  def check
    transaction_id = params[:transaction_id]
    response = IdealMollie.check_order(transaction_id)

    if response.paid
      # TODO: store the result information for the paid payment
      # For example:
      #   my_order = MyOrder.find_by_transaction_id(transaction_id)
      #   my_order.paid = true
      #   my_order.paid_on = Time.now
      #   my_order.customer_name = response.customer_name
      #   my_order.customer_account = response.customer_account
      #   my_order.customer_city = response.customer_city
      #   my_order.save
    else
      # TODO: store the result information for the canceled payment
      # For example:
      #   my_order = MyOrder.find_by_transaction_id(transaction_id)
      #   my_order.paid = false
      #   my_order.save
    end
    render :nothing => true
  end

  def result
    transaction_id = params[:transaction_id]
    # TODO show the result
    # For example:
    #   my_order = MyOrder.find_by_transaction_id(transaction_id)
    #   if my_order.paid
    #     render :text => "Thank you for your payment."
    #   else
    #     render :text => "Transaction has been cancelled or couldn't complete"
    #   end
  end
end
```

### View (transactions/index.html.erb)

```erb
<%= form_tag transaction_start_path, :method => :post do %>
  <%= select_tag "bank_id", options_from_collection_for_select(@banks, "id", "name") %>
  <%= button_submit_tag "Checkout" %>
<% end %>
```

## Changelog

A detailed overview can be found in the [CHANGELOG](https://github.com/manuelvanrijn/ideal-mollie/blob/master/CHANGELOG.md).

## Copyright

Copyright © 2012 Manuel van Rijn. See [LICENSE](https://github.com/manuelvanrijn/ideal-mollie/blob/master/LICENSE.md) for further details.

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/c3b01a288913d7f68d75d2fd837d9dcd "githalytics.com")](http://githalytics.com/manuelvanrijn/ideal-mollie)
