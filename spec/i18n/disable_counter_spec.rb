require "spec_helper"

RSpec.describe I18n::Counter do
  it "no calling redis when not enabled" do
    ENV['ENABLE_I18N_COUNTER'] = 'false'
    expect(I18n::Counter::I18nRedis).not_to receive(:connection)
    I18n.backend.translate(:en, 'foo.bar')
  end
end
