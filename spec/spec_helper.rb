require "bundler/setup"
require 'mock_redis'
require "i18n/counter"
Redis = MockRedis

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.before :suite do
    ENV['ENABLE_I18N_COUNTER'] = 'true'
    I18n.available_locales = ['en', 'nb']
  end
  config.before :each do
      I18n::Counter::I18nRedis.connection.flushdb
  end
  # seed
  I18n.backend.store_translations(:en, foo: { bar: 'baz' })
end
