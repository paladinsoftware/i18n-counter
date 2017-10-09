require "spec_helper"

RSpec.describe I18n::Counter::Summary do
  let(:redis) { I18n::Counter::I18nRedis.connection }

  context "redis registered keys" do
    before do
      redis.incr('en.foo.bar.default')
      redis.incr('en.foo.bar.baz')
      redis.incr('en.foo.baz.bar')
      redis.incr('en.foo.baz.bar') #2nd access
      redis.incr('nb.foo.bar.th.anotherlanguage')
      redis.incr('en.food.vegan')
      redis.incr('nb.foo.bar.default') # same key, another locale
    end

    context "key lookup count" do
      it "total across all locales" do
        expect(subject.count_all).to eq(5)
      end

      it "total english" do
        expect(subject.count_by_locale('en')).to eq(4)
      end
    end

    context "sum lookups" do
      it "across all locales" do
        expect(subject.sum_all).to eq(7)
      end

      it "english" do
        expect(subject.sum_by_locale('en')).to eq(5)
      end
    end

    context "compared to the native keys from locale files" do
      context "unused keys" do
        it "across all languages" do
          res = subject.call.unused
          expect{ res -= ['home','test.title'] }.to change{ res.size }.by(-2)
        end

        it "for english only"
      end

      context "used keys" do
        it "across all languages" do
          expect(subject.call.used.size).to eq(5)
        end
      end
    end

  end

  context "listed locales" do
    it "all native keys" do
      keys = subject.list_native_keys
      expect{ keys -= ["test.title", "test.description"]}.to change{ keys.size }.by(-2)
    end
  end
end
