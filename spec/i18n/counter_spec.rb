require "spec_helper"

RSpec.describe I18n::Counter do
  it "has a version number" do
    expect(I18n::Counter::VERSION).not_to be nil
  end

  context "on translate lookup" do
    context "translation found" do
      it "increments counter" do
        expect{ I18n.backend.translate(:en, 'foo.bar') }.to change{
          I18n::Counter::I18nRedis.connection.get('en.foo.bar').to_i
        }.by(1)
      end
    end
    context "missing translation" do
      it "increments counter" do
        expect do
          result = catch(:exception) do
            I18n.backend.translate(:en, 'bar.food')
          end
          expect(result.message).to match(/translation missing/)
        end.to change{
          I18n::Counter::I18nRedis.connection.get('en.bar.food').to_i
        }.by(1)
      end
    end
  end
end
