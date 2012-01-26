# Ideal Mollie (ideal-mollie) [![Build Status](https://secure.travis-ci.org/manuelvanrijn/ideal-mollie.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/manuelvanrijn/ideal-mollie.png)][gemnasium]

[travis]: http://travis-ci.org/manuelvanrijn/ideal-mollie
[gemnasium]: https://gemnasium.com/manuelvanrijn/ideal-mollie

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

### Transaction Controller

```
class TransactionsController < ApplicationController
  def index
    @banks = IdealMollie.banks
  end

  def start
    # redirect to banks if there is no bank_id given
    redirect_to transaction_path if params[:bank_id].nil?
    bank_id = params[:bank_id]

    # 10,00 EUR
    request = IdealMollie.new_order(1000, 'some payment description', bank_id)

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

    if response.payed
      # TODO: store the result information for the payed payment
      # For example:
      #   my_order = MyOrder.find_by_transaction_id(transaction_id)
      #   my_order.payed = true
      #   my_order.payed_on = Time.now
      #   my_order.customer_name = response.customer_name
      #   my_order.customer_account = response.customer_account
      #   my_order.customer_city = response.customer_city
      #   my_order.save
    else
      # canceled or re-checking?
      if my_order.payed.nil?
        # TODO: store the result information for the canceled payment
        # For example:
        #   my_order = MyOrder.find_by_transaction_id(transaction_id)
        #   my_order.payed = false
        #   my_order.save
      end
    end
    render :nothing => true
  end

  def result
    # TODO show the result
    # For example:
    #   my_order = MyOrderObject.find(id)
    #if @my_order.payed
      render :text => "Thank you for your payment."
    else
      render :text => "Transaction has been cancelled or couldn't complete"
    end
  end
end
```

### View (transactions/index.html.erb)

```
<%= form_tag transaction_start_path, :method => :post do %>
  <%= select_tag "bank_id", options_from_collection_for_select(@banks, "id", "name") %>
  <%= button_submit_tag "Checkout" %>
<% end %>
```

## Changelog

A details overview could be found in the [CHANGELOG](https://github.com/manuelvanrijn/ideal-mollie/blob/master/CHANGELOG.md).

## Copyright

Copyright © 2012 Manuel van Rijn. See [LICENSE](https://github.com/manuelvanrijn/ideal-mollie/blob/master/LICENSE.md) for further details.
