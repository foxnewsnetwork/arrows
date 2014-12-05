# Arrows

A library to bring some of the best elements of Haskell functional programming into Ruby.

Except, where Haskell is overly general and nigh unapproachable, here I try to build an
actually useful set of functional tools for day-to-day Ruby programming

Features:

*note, see spec/arrows/proc_spec.rb to get an idea how to use this junk
### Function composition

If given
x -> F -> y and y -> G -> z

Returns
x -> H -> z

As in we pipe what F poops out into the mouth of G a la Human Centipede


### Applicative composition
Calls map (in Haskell, they generalize it to fmap) on the data passed in

So... If given
x -> F -> y and [x]

Returns
[x] -> F -> [z]

### Arrow fan out
x -> y
x -> z
becomes
x -> [y,z]

### Arrow split
Not implemented

## Use Case
Suppose you're running rails (lol what else is there in ruby?) for some sort of ecommerce app and you have an OfferController that handles inputs from an user who is trying to make an offer on some listing you have. Your controller might look like this:

```ruby
class OfferController < ApplicationController
  rescue_from ActiveRecord::HasCancer
  def create
    if user_signed_in?
      offer = current_user.offers.new offer_params
    else
      user = User.create! offer_params[:user]
      login_in(user)
      offer = user.offers.new offer_params
    end
    if offer.valid?
      if offer.save!
        mail = OfferNotificationMailer.new_offer offer
        mail.deliver!
        render offer
      end
    else
      if ...cancer
    end
  end
  private
  def stuff
  ...
end

class Offer < ActiveRecord::Base
  ...
  after_create :queue_some_job, :dispatch_invoice
  ...
end
```
If it does, I'm sorry to inform you, but your codebase has cancer. Functional Arrows can help resolve this by linearization your currently highly nonlinear Object-Oriented business logic

```ruby
class OfferController < ApplicationController
  def create
    offer_creation_process.call
  end
  private
  def offer_creation_process
    offer_params >> initialize_user >> initialize_new_offer >> persist_offer >> deliver_mail / render_view
  end
  def offer_params
    ...
  end
  def initialize_user
    ...
  end
  ...
end
```
That is, offer creation has been reduced back down to a process with distinct steps. 
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'arrows'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install arrows

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/arrows/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
