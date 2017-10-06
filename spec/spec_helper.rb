require "bundler/setup"
require 'mock_redis'
require "i18n/counter"
require 'pry'
Redis = MockRedis

Dir['spec/support/**/*.rb'].each { |f| require "./#{f}" }


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
      allow_any_instance_of(I18n::Counter::Summary).to receive(:load_locales).and_return(I18n::Tasks::BaseTask.new(data: { read: ["spec/support/config/locales/%{locale}.yml"]}))

  end
  # seed
  I18n.backend.store_translations(:en, foo: { bar: 'baz' })
end
