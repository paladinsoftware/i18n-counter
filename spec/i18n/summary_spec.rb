require "spec_helper"

RSpec.describe I18n::Counter::Summary do
  let(:redis) { I18n::Counter::I18nRedis.connection }

  context "redis registered keys" do
    before do
      redis.incr('en.foo.bar')
      redis.incr('en.foo.bar.baz')
      redis.incr('en.foo.baz.bar')
      redis.incr('en.foo.baz.bar') #2nd access
      redis.incr('nb.foo.bar.th.anotherlanguage')
      redis.incr('en.bar.food.not.healthy')
      redis.incr('nb.foo.bar') # same key, another locale
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
  end

  context "listed locales" do
    it "lists keys of own locales only, not gem dependencies"
  end

  context "listed locales and redis registry" do
    context "unused keys" do
      it "across all languages"

      it "for english only" do
        keys = []
        subject.available_keys('en') { |k| keys << k}
        expect{ keys -= ["test.title", "test.description"]}.to change{ keys.size }.by(-2)
      end
    end
  end

end
