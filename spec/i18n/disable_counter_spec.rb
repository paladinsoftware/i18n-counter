ENV['ENABLE_I18N_COUNTER'] = 'false'
require "bundler/setup"
require 'mock_redis'
require "i18n/counter"

RSpec.describe I18n::Counter do
  it "no mixin when not enabled" do
    expect(I18n::Backend::Simple).not_to include(I18n::Counter::Hook)
  end
end
