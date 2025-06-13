source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bcrypt", "~> 3.1.7"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "thruster", require: false

group :development do
  gem "hotwire-spark"
  gem "htmlbeautifier"
  gem "kamal", "~> 2.6"
  gem "letter_opener"
  gem "solargraph"
  gem "web-console"
end

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "dotenv"
  gem "standard"
  gem "standard-rails"
end

group :test do
  gem "capybara"
  gem "mocha"
  gem "selenium-webdriver"
  gem "webmock"
end

gem "arclight", "~> 2.0.alpha", git: "https://github.com/projectblacklight/arclight", ref: "086061a", require: false
gem "aws-sdk-s3", require: false
gem "pagy"
gem "oai", "~> 1.3"
gem "traject", "~> 3.8"
