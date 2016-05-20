# Database Cleaner

[![Build Status](https://travis-ci.org/DatabaseCleaner/database_cleaner-mongoid.svg?branch=master)](https://travis-ci.org/DatabaseCleaner/database_cleaner-mongoid)
[![Code Climate](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-mongoid/badges/gpa.svg)](https://codeclimate.com/github/DatabaseCleaner/database_cleaner-mongoid)

Database Cleaner is a set of strategies for cleaning your database in Ruby.

The original use case was to ensure a clean state during tests.
Each strategy is a small amount of code but is code that is usually needed in any ruby app that is testing with a database.

## Gem Setup

```ruby
# Gemfile
group :test do
  gem 'database_cleaner-mongoid'
end
```

## Supported Strategies

Here is an overview of the supported strategies:

<table>
  <tbody>
    <tr>
      <th>ORM</th>
      <th>Truncation</th>
      <th>Transaction</th>
      <th>Deletion</th>
    </tr>
    <tr>
      <td> Mongoid</td>
      <td> <b>Yes</b></td>
      <td> No</td>
      <td> No</td>
    </tr>
  </tbody>
</table>

(Default strategy is denoted in bold)

For support or to discuss development please use the [Google Group](http://groups.google.com/group/database_cleaner).

## How to use

```ruby
require 'database_cleaner/mongoid'

DatabaseCleaner.strategy = :truncation

# then, whenever you need to clean the DB
DatabaseCleaner.clean
```

With the `:truncation` strategy you can also pass in options, for example:

```ruby
DatabaseCleaner.strategy = :truncation, {:only => %w[widgets dogs some_other_table]}
```

```ruby
DatabaseCleaner.strategy = :truncation, {:except => %w[widgets]}
```

(I should point out the truncation strategy will never truncate your schema_migrations table.)

### RSpec Example

```ruby
RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end
```

### RSpec with Capybara Example

You'll typically discover a feature spec is incorrectly using transaction
instead of truncation strategy when the data created in the spec is not
visible in the app-under-test.

A frequently occurring example of this is when, after creating a user in a
spec, the spec mysteriously fails to login with the user. This happens because
the user is created inside of an uncommitted transaction on one database
connection, while the login attempt is made using a separate database
connection. This separate database connection cannot access the
uncommitted user data created over the first database connection due to
transaction isolation.

For feature specs using a Capybara driver for an external
JavaScript-capable browser (in practice this is all drivers except
`:rack_test`), the Rack app under test and the specs do not share a
database connection.

When a spec and app-under-test do not share a database connection,
you'll likely need to use the truncation strategy instead of the
transaction strategy.

See the suggested config below to temporarily enable truncation strategy
for affected feature specs only. This config continues to use transaction
strategy for all other specs.

It's also recommended to use `append_after` to ensure `DatabaseCleaner.clean`
runs *after* the after-test cleanup `capybara/rspec` installs.

```ruby
require 'capybara/rspec'

#...

RSpec.configure do |config|

  config.use_transactional_fixtures = false

  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end
    DatabaseCleaner.clean_with(:truncation)
  end  

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    if !driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

end
```

### Minitest Example

```ruby
DatabaseCleaner.strategy = :truncation

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end

# with the minitest-around gem, this may be used instead:
class Minitest::Spec
  around do |tests|
    DatabaseCleaner.cleaning(&tests)
  end
end
```

### Cucumber Example

If you're using Cucumber with Rails, just use the generator that ships with cucumber-rails, and that will create all the code you need to integrate DatabaseCleaner into your Rails project.

Otherwise, to add DatabaseCleaner to your project by hand, create a file `features/support/database_cleaner.rb` that looks like this:

```ruby
begin
  require 'database_cleaner/mongoid'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner-mongoid to your Gemfile (in the :test group) if you wish to use it."
end

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end
```

### Configuration options

<table>
  <tbody>
    <tr>
      <th>ORM</th>
      <th>How to access</th>
      <th>Notes</th>
    </tr>
    <tr>
      <td> Mongoid</td>
      <td> <code>DatabaseCleaner[:mongoid]</code></td>
      <td> Multiple databases supported for Mongoid 3. Specify <code>DatabaseCleaner[:mongoid, {:connection =&gt; :db_name}]</code> </td>
    </tr>
  </tbody>
</table>

## Common Errors

#### DatabaseCleaner is trying to use the wrong ORM

DatabaseCleaner has an autodetect mechanism where if you do not explicitly define your ORM it will use the first ORM it can detect that is loaded.

Since ActiveRecord is the most common ORM used that is the first one checked for.

Sometimes other libraries (e.g. ActiveAdmin) will load other ORMs (e.g. ActiveRecord) even though you are using a different ORM.  This will result in DatabaseCleaner trying to use the wrong ORM (e.g. ActiveRecord) unless you explicitly define your ORM like so:

```ruby
# How to setup your ORM explicitly
DatabaseCleaner[:mongoid].strategy = :truncation
```

## Debugging

In rare cases DatabaseCleaner will encounter errors that it will log.  By default it uses STDOUT set to the ERROR level but you can configure this to use whatever Logger you desire.

Here's an example of using the `Rails.logger` in `env.rb`:

```ruby
DatabaseCleaner.logger = Rails.logger
```


## COPYRIGHT

See [LICENSE](LICENSE) for details.
