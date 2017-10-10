# I18n::Counter

Learn about locales you rarely or never use.

WIP - This is Work In Progress.

This gem hooks into the I18n lookup process and reports on keys being accessed. It connects to Redis and increments the counter for the key.

That way you can later compare with your project locale files and identify keys that has not had a single hit. It increments the counter per key per language/locale, so you may identify usages across locales as well.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'i18n-counter'
```

To enable the tracking

    $ export ENABLE_I18N_COUNTER=true

To disable, set

    $ export ENABLE_I18N_COUNTER=true

To configure what Redis will it use, i18n-counter will look for ENV vars in this order

```ruby
ENV['I18N_REDIS_URL'] || ENV[ENV['REDIS_PROVIDER'] || 'REDIS_URL']
```

if all is nil, it'll be a plain `Redis.new`, using default local redis instance.

## Usage

First of all, this needs time. Time to track and collect usage.

Pull unused (so far) native translation keys - we define the native keys as those listed in your projects config/locale/*.yml files.

```ruby
summary = I18n::Counter::Summary.new.call
summary.unused
=> ['en.keygroup.key1'. 'en.keygroup2.key2' ,...]
````

Used native keys

```ruby
summary = I18n::Counter::Summary.new.call
summary.used
=> ['en.keygroup.key2'. 'en.keygroup2.key3' ,...]
```

All keys of project config/locales/en.yml

```ruby
summary.list_native_keys 'en'
```

All key lookups. List array of all keys looked up -from a t('some_key') that triggers the translate lookup. _Note:_ This may show many more keys than the native keys count. This comes from whatever libraries you use. Perhaps you use ActiveAdmin or other. Or you got an english only backoffice in own locale files that isn't track.

```ruby
summary.accessed_keys 'en'
```

Some sugar:

```ruby
#sums the lookups across the keys
summary.sum_by_locale 'en'
#count the looked up keys
summary.count_by_locale 'en'
#compare for all locales
I18n.available_locales.map do |locale|
  summary.count_by_locale locale
end
```

## WARNINGS

### Speed
This solution slows down your lookups. Not by much, but depending on the number of lookups you do per request in your app.

Benchmark shows approx 5x slower (note that this is 5x of something fast.). doing 100.000 lookups with/without REDIS hook

`100000.times I18n.t('en.test')`:

| Benchmark  | Seconds   | Sec pr translation |
|:----------:| ---------:| ---------:|
| with redis | 48.280000 | 0.0004828 |
| without    |  9.010000 | 0.0000901 |


### Redis size and connections

If you go with the default and you use Sidekiq, you are likely to be using same Redis instance. The i18n-counter doesn't take a lot of space, that dependes on the size of your locales, but it still consumes some.
Using same Redis instance is mainly risky for the reason of human error. A purge, flushall, would also clean the sidekiq queues.

If you run many processes (dynos, puma threads or other), you create a Redis connection for all. Be aware of that.

### WIP

missing summary, reports, movement over time, resets.

Hey, I just got started, need to allow production to gather data so I can make reports...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Lots to do ! :)

Better reports. Timelines. Configs for other setups than ours.

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/i18n-counter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

