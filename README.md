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

## Sub-Modules

This library is broken down into several bounded contexts that can be consumed either via its Ruby API's or CLI through provided executable scripts:

![Basketball Architecture - Overview](/docs/architecture/overview.png)

## Drafting Module

The drafting module is responsible for providing a turn-based iterator allowing the consumer to either manually pick or simulate picks.  Here is a cartoon showing the major components:

![Basketball Architecture - Drafting](/docs/architecture/drafting.png)

Element      | Description
:------------ | :-----------
**Drafting** | Bounded context (sub-module) dealing with executing an asynchronous draft.
**Engine** | Aggregate root responsible for providing an iterable interface capable of executing a draft, pick by pick.
**Event** | Represents one cycle execution result from the Engine.
**External Ruby App** | An example consumer for the Drafting context.
**Front Office** | Identifiable as a team, contains configuration for how to auto-pick draft selections.
**League** | Set of rosters that together form a cohesive league.
**Pick Event** | Result event emitted when a player is manually selected.
**Player** | Identitiable as a person able to be drafted.
**Position** | Value object based on position code: PG, SG, SF, PF, and C.
**Roster** | Identifiable as a team, set of players that make up a single team.
**Sim Event** | Result event emitted when a player is automatically selected by a front office.
**Skip Event** | Result event emitted when a front office decides to skip a round.

### The Drafting CLI

The drafting module is meant to be interfaced with using its Ruby API by consuming applications.  It also ships with a CLI which a user can interact with to emulate "the draft process".  Technically speaking, the CLI provides an example application built on top of the Drafting module.  Each time a CLI command is executed, its results will be resaved, so the output file can then be used as the next command's input file to string together commands.  The following sections are example CLI interactions:

##### Generate a Fresh Draft

```zsh
basketball-draft -o tmp/draft.json
```

##### N Top Available Players

```zsh
basketball-draft -i tmp/draft.json -t 10
```

##### N Top Available Players for a Position

```zsh
basketball-draft -i tmp/draft.json -t 10 -q PG
```

##### Output Current Rosters

```zsh
basketball-draft -i tmp/draft.json -r
```

##### Output Event Log

```zsh
basketball-draft -i tmp/draft.json -l
```

##### Simulate N picks

```zsh
basketball-draft -i tmp/draft.json -s 10
```

##### Skip N picks

```zsh
basketball-draft -i tmp/draft.json -x 10
```

##### Pick Players

```zsh
basketball-draft -i tmp/draft.json -p P-100,P-200,P-300
```

##### Simulate the Rest of the Draft

```zsh
basketball-draft -i tmp/draft.json -a
```

##### Help Menu

```zsh
basketball-draft -h
```

## Scheduling Module

The Scheduling module is meant to take a League (conferences/divisions/teams) and turn it into a Calendar.  This Calendar creation is atomic - the full calendar will be generated completely all in one call.  Here is a cartoon showing the major components:

![Basketball Architecture - Scheduling](/docs/architecture/scheduling.png)

Element      | Description
:------------ | :-----------
**Away Team** | Team object designated as the away team for a Game.
**Calendar Serializer** | Understands how to serialize and deserialize a Calendar object.
**Calendar** | Hold a calendar for a year season.  Pass in a year and the Calendar will know how to mark important boundary dates (preseason start, preseason end, season start, and season end) and it knows how to ensure Calendar correctness regarding dates.
**Conference** | Describes a conference in terms of structure; composed of an array of divisions (there can only 3).
**Coordinator** | Service which can generate a Calendar from a League.
**Division** | Describes a division in terms of structure; composed of an array of teams (there can only 5).
**Game** | Matches up a date with two teams (home and away) to represent a scheduled matchup.
**Home Team** | Team object designated as the home team for a Game.
**League Serializer** | Understands how to serialize and deserialize a League object.
**League** | Describes a league in terms of structure; composed of an array conferences (there can only be 2).
**Scheduling** | Bounded context (sub-module) dealing with matchup and calendar generation.
**Team** | Identified by an ID and described by a name: represents a basketball team that can be scheduled.

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
