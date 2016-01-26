# Seiso::ImportChef

[![Gem Version](https://badge.fury.io/rb/seiso-import_chef.svg)](http://badge.fury.io/rb/seiso-import_chef)
[![Build Status](https://travis-ci.org/ExpediaDotCom/seiso-import_chef.svg)](https://travis-ci.org/ExpediaDotCom/seiso-import_chef)
[![Inline docs](http://inch-ci.org/github/ExpediaDotCom/seiso-import_chef.svg?branch=master)](http://inch-ci.org/github/ExpediaDotCom/seiso-import_chef)

Imports Chef data into Seiso. See [Integrate Chef Server Data Using Seiso](http://seiso.io/guides/integrate-chef-server-data-using-seiso/) for more details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seiso-import_chef'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seiso-import_chef

## Usage

1. Create a directory `~/.seiso-importers`
2. Place appropriately modified copies of `chef.yml.sample` and `seiso3.yml.sample` in there.
3. Run `seiso-import-chef` to do the import.

## Contributing

1. Fork it ( https://github.com/ExpediaDotCom/seiso-import_chef/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request.
