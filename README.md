# Sagan [![Build Status](https://api.travis-ci.org/SchoolKeep/sagan.svg)](https://magnum.travis-ci.com/SchoolKeep/sagan)

Deploy SchoolKeep to an experimental server

[http://www.exp1.schoolify.me](http://www.exp1.schoolify.me) -> 
[http://www.exp10.schoolify.me](http://www.exp10.schoolify.me)

## Installation

Add this line to your application's Gemfile:

    gem 'sagan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sagan

## Usage

Deploy your current branch to an open experimental server

    $ rake sagan:up

Once you're finished with the experimental server make it available for 
someone else. You can use the following command where `N` is the number of 
the experimental server your were using.

    $ rake sagan:down[expN]

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sagan/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
