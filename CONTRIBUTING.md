# Contributing guide

## Installing daru development dependencies

Install [Daru](https://github.com/SciRuby/daru) dependencies : [installing-daru-development-dependencies](https://github.com/SciRuby/daru/blob/master/CONTRIBUTING.md#installing-daru-development-dependencies)


Then install remaining dependencies:

  `bundle install`

And run the test suite (should be all green with pending tests):

  `bundle exec rspec`

If you have problems installing nmatrix, please consult the [mailing list](https://groups.google.com/forum/#!forum/sciruby-dev).

While preparing your pull requests, don't forget to check your code with Rubocop:

  `bundle exec rubocop`


## Basic Development Flow

1. Create a new branch with `git checkout -b <branch_name>`.
2. Make your changes. Write tests covering every case how your feature will be used. If creating new files for tests, refer to the 'Testing' section [below](#Testing).
3. Try out these changes with `rake pry`.
4. Run the test suite with `rake spec`. (Alternatively you can use `guard` as described [here](https://github.com/SciRuby/daru/blob/master/CONTRIBUTING.md#testing). Also run Rubocop coding style guidelines with `rake cop`.
5. Commit the changes with `git commit -am "briefly describe what you did"` and submit pull request.

[Optional] You can run rspec for all Ruby versions at once with `rake spec run all`. But remember to first have all Ruby versions installed with `ruby spec setup`.


## Testing


  `bundle exec rspec`

**NOTE**: Please make sure that you place test for your file at the same level and with same itermediatary directories. For example if code file lies in `lib/xyz/abc.rb` then its corresponding test should lie in `spec/xyz/abc_spec.rb`. This is to ensure correct working of Guard.

## How daru-view is created

GSoc 2017 Blog posts : [http://shekharrajak.github.io/gsoc_2017_posts/](http://shekharrajak.github.io/gsoc_2017_posts/)

