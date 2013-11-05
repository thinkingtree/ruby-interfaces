# Interfaces

## Installation

Add this line to your application's Gemfile:

    gem 'interfaces'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install interfaces

## Usage

Ruby is a fun, super-flexible language that lets us as developers do almost anything we can dream of.  Sometimes we do great with that kind of freedom, but other times we need stricter rules to help guide us.  Interfaces is a library designed to help put some enforcement around the way that duck-typing is used in ruby.  It allows us to ask the question 'does this object have the methods I need?' and then to say 'thanks, I promise to only call these methods.'  It also helps to make code more readable, by stating 'I'm expecting you to give me an object that has these methods.'

Let's role play a development scenario.  Let's say you are writing an application that will send mail through a user's mail server.  You're going to store the user's configuration on the User model.  To keep this example simple, we won't use ActiveRecord for our model, just a plain old class:

    class User
      # some properties of the user
      attr_accessor :username

      # some options specifically for sending mail
      attr_accessor :email_server, :use_ssl?, :port, :use_html?

  	  def email_sent_callback(mailer)
	   	  # do something after mail is sent
	    end
    end

And we create a MailerService to send mail:

    class MailerService
      attr_accessor :user, :to, :subject, :message

      def initialize(user, to, subject, message)
      	self.user = user
      	self.to = to
      	self.subject = subject
      	self.message = message
      end

      def deliver
        # ... implement mail sending here
        user.email_sent_callback(self)
      end
    end

We can call the Mailer service and pass it a user:

  MailerService.new(user, 'bob@example.com', 'test message', 'hello world!').deliver

Looking at the line of code above, one might wonder why a user is being passed into the mailer service.  One might also wonder what properties of 'user' the mailer service is actually using.  Is the mailer only reading properties of my user or is it *changing* the user?  What if another developer comes along, noticing that the mailer is receiving a User model, and inadvertantly tightly couples MailerService to the User model?  That may not cause immediate problems, but down the road services and models can become more and more tightly coupled.  When you find yourself needing to use your service somewhere else you might find the de-coupling refactor to be a daunting task...

The Mailer service does not really need a User, what it needs is configuration.  So let's re-write this code using Interfaces.  First, let's define an interface:

	class MailerConfiguration < Interface
		abstract :email_server, :use_ssl?, :port, :use_html?, :email_sent_callback
	end

Then, when we call our mailer service it will cast whatever object is passed in to be a MailerConfiguration object:

  class MailerService
    attr_accessor :config, :to, :subject, :message

    def initialize(config, to, subject, message)
      self.config = config.as(MailerConfiguration)
      ...

Now it's clear that the user is being passed in because it contains configuration information.  Further, there is enforcement taking place-- if User did not implement one of the four required methods, a clear exception would be fired at runtime.  And if MailerService tries to call another method of User that is not defined in the MailerConfiguration interface, an exception will be thrown.  Lastly, there's one place to look to determine what methods are needed by MailerConfiguration-- the code is self documenting.

Behind the scenes what is really happening here is that a new MailerConfiguration instance is being created, and then the abstract methods are being redefined on that instance to proxy to the equivalent methods on the 'user' object.

Interfaces have a few other capabilities.  First, they can be instantiated using a hash if you don't want to use duck typing, making them much more like a Struct that can also contain arbitrary methods.

	config = MailerConfiguration.new(:email_server => 'myemailserver.com',
									  :port => 443,
									  :use_ssl? => true,
									  :use_html? => true,
									  :email_sent_callback => lambda { |s| puts "Mail sent!"})
	MailerService.new(config, 'bob@example.com', 'test message', 'hello world!').deliver

Interfaces can also be derived from other interfaces, both adding or removing abstract methods:

	class SecureMailerConfiguration < MailerConfiguration
		abstract :vpn

		# always use ssl
		def use_ssl?
			true
		end
	end

This breaks away from the traditional notion of 'interfaces' in that we're now implementing methods directly on an interface.  This practice is much more similar to the notion of abstract classes in other languages.  Let's view the abstract methods of both of these interfaces:

	MailerConfiguration.abstract_methods
	=> [:email_server, :use_ssl?, :port, :use_html?, :email_sent_callback]

	SecureMailerConfiguration.abstract_methods
	=> [:vpn, :email_server, :port, :use_html?, :email_sent_callback]

Note that the use_ssl? method is no longer abstract in the SecureMailerConfiguration interface because it has been implemented.

## Optional methods

An interface may contain optional methods. If they are defined by a class then they will be delegated to, but if they are not defined they will simply return nil.  This alleviates the developer from having to add respond_to? checks before calling methods that may or may not be defined.

    class TestInterface < Interface
      abstract :field1
      optional :field2
    end

    TestInterface.new.field2
    => nil

## Checking conformance

    User.conforms_to?(TestInterface)
    => true

## Typed accessors

The typed_attr_accessor and typed_attr_writer helpers make it easy to create attributes that always conform to an interface:

    class MailerService
      typed_attr_accessor :config => MailerConfiguration
      # ...
    end

Now when the 'config' attribute is assigned it will be automatically converted to an instance of MailerConfiguration or it will raise an exception if it cannot be converted.

## Built-in and custom conversions for non-interfaces

For the basic ruby types (String, Symbol, Integer, Float, Array, Hash (on ruby 2.0)) there are built-in conversions that simply call the corresponding standard ruby conversion method (to_s, to_sym, to_i, to_f, to_a, to_h):

    "test".as(Symbol) == :test

This allows the typed_attr_accessor to be used with these standard types.

Additional custom conversions can be defined by overriding the 'as' method in a class.

## Interface caching and state

Interfaces are full-fledged ruby classes, and as such they can have methods and instance variables (state).  To ensure that this state is maintained each time the object is cast, an interface cache is maintained on any object that has been casted at least once.  This means that the following is always true:

	user.as(MailerConfiguration) === user.as(MailerConfiguration)

## Usage with the 'contracts' gem

The 'interfaces' gem does not enforce that a parameter passed to a method conforms to an interface, but this can be achieved by using the [contracts gem](https://github.com/egonSchiele/contracts.ruby):

	class MailerService
      attr_accessor :configuration, :to, :subject, :message

	  Contract MailerConfiguration, String, String, String => MailerService
      def initialize(configuration, to, subject, message)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
