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

### Arrow Fork
f ^ g produces a proc that takes in a Either, and if either is good, f is evaluated, if either is evil, g is evaluated

### ArrowLoop
step <=> chose produces a proc that cycles between step and chose until chose returns a good either. Then returns whatever was in the good either

```ruby
context '<=> feedback' do
    let(:step) { Arrows.lift -> (arg_acc) { [arg_acc.first - 1, arg_acc.reduce(&:*)] } }
    let(:chose) { Arrows.lift -> (arg_acc) { arg_acc.first < 1 ? Arrows.good(arg_acc.last) : Arrows.evil(arg_acc) } }
    let(:factorial) { step <=> chose }
    context '120' do
      let(:one_twenty) { Arrows.lift(5) >> factorial }
      subject { one_twenty.call }
      specify { should eq 120 }
    end
    context '1' do
      let(:one) { Arrows.lift(1) >> factorial }
      subject { one.call }
      specify { should eq 1 }
    end
    context '0' do
      let(:zero) { Arrows.lift(0) >> factorial }
      subject { zero.call }
      specify { should eq 0 }
    end
  end
```

## Memoization
```ruby
@some_process = Arrows.lift -> (a) { a }
@memoized_process = @some_process.memoize
```

## Catching errors
```ruby
@times_two = Arrows.lift -> (x) { x * 2 }
@plus_one = Arrows.lift -> (x) { x == 4 ? raise(SomeError, "error: #{x}") : (x + 1) }
@times_two_plus_one = @times_two >> @plus_one
@caught_process = @times_two_plus_one.rescue_from(SomeError) { |error, arg| "we fucked up on: #{arg}" }
@caught_process.call 1 # 3
@caught_process.call 2 # we fucked up on: 2
```

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

### Another Example
Here's an example directly from one of my other applications
```ruby
class Apiv1::Contacts::UpdateController < Apiv1::UsersController
  before_filter :_enforce_correct_user
  def update
    _update_process.call
  end
  private
  def _enforce_correct_user
    unless current_user.admin? || current_user.contacts.include?(_contact)
      render json: { message: "This isn't your listing" }, status: 401
    end
  end
  def _update_process
    _user_inputs >> _apply_changes >> _decide_validity >> (_update_valid_data_process ^ _render_failure)
  end
  def _update_valid_data_process
    _save_changes >> _decide_primality >> (_make_primary ^ Arrows::ID) >> _render_success 
  end
  def _user_inputs
    Arrows.lift _contact
  end
  def _apply_changes
    Arrows.lift -> (contact) { contact.tap { |p| p.assign_attributes _contact_params } }
  end
  def _decide_validity
    Arrows.lift -> (contact) { contact.valid? ? Arrows.good(contact) : Arrows.evil(contact) }
  end
  def _decide_primality
    Arrows.lift -> (contact) { _contact_params[:status] == "primary" ? Arrows.good(contact) : Arrows.evil(contact) }
  end
  def _render_success
    Arrows.lift -> (contact) { render json: { contact: contact.to_ember_hash } }
  end
  def _save_changes
    Arrows.lift -> (contact) { contact.tap(&:save!) }
  end
  def _make_primary
    Arrows.lift -> (contact) { contact.tap &:make_primary! }
  end
  def _render_failure
    Arrows.lift -> (contact) { render json: contact.errors.to_h, status: :expectation_failed }
  end
  def _contact
    @contact ||= Apiv1::UserContact.find params[:id]
  end
  def _contact_params
    @contact_params ||= params.require(:contact).permit(:name, :phone, :email, :address, :status)
  end
end
```
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
