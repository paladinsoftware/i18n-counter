require "spec_helper"

RSpec.describe I18n::Counter do
  it "has a version number" do
    expect(I18n::Counter::VERSION).not_to be nil
  end

  context "incrementing counter" do
    before do
      I18n.backend.store_translations(:en, foo: { bar: 'baz' })
      # Avoid I18n deprecation warning:
      I18n.enforce_available_locales = true
    end
    it "does something useful" do
      I18n.backend.translate(:en, 'foo.bar')
      expect{ I18n.backend.translate(:en, 'foo.bar') }.to change{
          I18n::Counter::I18nRedis.connection.get('en.foo.bar').to_i
        }.by(1)
    end
  end
end
