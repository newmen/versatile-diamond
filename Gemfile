source 'https://rubygems.org'

group :ruby do
  gem 'activesupport'
  gem 'docopt'
  gem 'ffi'
  gem 'i18n'
  gem 'multiset'
  gem 'ruby-graphviz'
end

group :ruby, :test do
  gem 'rspec'
  gem 'parallel_tests'
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

group :cpp do
  gem 'gnuplot'
end

group :cpp, :test do
  gem 'colorize' # for c++ specs
end

# support
group :debug do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  # gem 'pry-rescue'
end
