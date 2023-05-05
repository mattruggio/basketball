# :basketball: Basketball

[![Gem Version](https://badge.fury.io/rb/basketball.svg)](https://badge.fury.io/rb/basketball) [![CI](https://github.com/mattruggio/basketball/actions/workflows/ci.yaml/badge.svg)](https://github.com/mattruggio/basketball/actions/workflows/ci.yaml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

#### Basketball League Game Engine

This library is meant to serve as the domain for a basketball league/season simulator/turn-based game. It models core ideas such as: players, general managers, draft strategy, drafting, season generation, season simultation, playoff generation, playoff simulation, and more.

## Installation

To install through Rubygems:

````
gem install basketball
````

You can also add this to your Gemfile using:

````
bundle add basketball
````

Install executable scripts:

````
bundle binstubs basketball
````

## Main Modules

This library is broken down into several bounded contexts that can be consumed either via its Ruby API's or CLI through provided executable scripts:

![Basketball Architecture - Overview.png](/docs/architecture/overview.png)

## Drafting Module

The drafting module is responsible for providing a turn-based iterator allowing the consumer to either manually pick or simulate picks.  Here is a cartoon showing the major components:

![Basketball Architecture - Drafting.png](/docs/architecture/drafting.png)

### The Drafting CLI

The drafting module is meant to be interfaces using its Ruby API by consuming applications.  It also ships with a CLI which a user can interact with to emulate "the draft process".  Technically speaking, the CLI provides an example application built on top of the Drafting module.  Each time a CLI command is executed, its results will be resaved, so the output file can then be used as the next command's input file to string together commands.  The following sections are example CLI interactions:

#### Generate a Fresh Draft

```zsh
basketball-draft -o tmp/draft.json
```

#### N Top Available Players

```zsh
basketball-draft -i tmp/draft.json -t 10
```

#### N Top Available Players for a Position

```zsh
basketball-draft -i tmp/draft.json -t 10 -q PG
```

#### Output Current Rosters

```zsh
basketball-draft -i tmp/draft.json -r
```

#### Output Event Log

```zsh
basketball-draft -i tmp/draft.json -l
```

#### Simulate N picks

```zsh
basketball-draft -i tmp/draft.json -s 10
```

#### Skip N picks

```zsh
basketball-draft -i tmp/draft.json -x 10
```

#### Pick Players

```zsh
basketball-draft -i tmp/draft.json -p P-100,P-200,P-300
```

#### Simulate the Rest of the Draft

```zsh
basketball-draft -i tmp/draft.json -a
```

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check basketball.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:mattruggio/basketball.git)
4. Navigate to the root folder (cd basketball)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````zsh
bin/rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````zsh
bin/guard
````

Also, do not forget to run Rubocop:

````zsh
bin/rubocop
````

And auditing the dependencies:

````zsh
bin/bundler-audit check --update
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into main
2. Update `version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push main to remote and ensure CI builds main successfully
6. Run `bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mattruggio/basketball/blob/main/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
