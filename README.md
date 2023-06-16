# Basketball

[![Gem Version](https://badge.fury.io/rb/basketball.svg)](https://badge.fury.io/rb/basketball) [![CI](https://github.com/mattruggio/basketball/actions/workflows/ci.yaml/badge.svg)](https://github.com/mattruggio/basketball/actions/workflows/ci.yaml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

:warning: **Note:** This is currently in the early phases of initial development. Consider all < 1 releases as having unstable APIs between versions. A formal 1.0.0 major release will be eventually released which will honor [Semver](https://semver.org/).

This library is meant to serve as the domain for a basketball league/season simulator/turn-based game. It models core ideas such as: players, general managers, draft strategy, drafting, season generation, season simultation, playoff generation, playoff simulation, and more.

![Architecture](/docs/architecture.png)

Element      | Description
:------------ | :-----------
**Arena** | Determines exhibition and regular season game outcomes.
**Assessment** | When the Room needs to know who a Front Office wants to select, the Room will send the Front Office an Assessment. The Assessment is a report of where the team currently stands: players picked, players available, and round information.
**Calendar** | Stores important boundary dates (exhibition start, exhibition end, season start, and season end).
**Conference** | A collection of Divisions.
**Coordinator** | Object which can take a League, Calendar, Games, and an Arena and provide an iterable interface to enumerate through days and simulate games as results.
**Detail** | Re-representation of a Result object but from a specific team's perspective.
**Division** | A collection of teams.
**Draft** | Bounded context (sub-module) dealing with running a round-robin player draft for teams.
**Exhibition** | Pre-season game which has no impact to team record.
**Free Agent** | A player who is not signed to any team but is able to be signed.
**Front Office** | Identifiable as a team, contains logic for how to auto-pick draft selections.  Meant to be subclassed and extended to include more intricate player selection logic as the base will simply randomly select a player.
**Game** | Matches up a date with two teams (home and away) to represent a coordinatord match-up.
**League** | Describes a league in terms of structure composed of conferences, divisions, teams, and players.
**Match** | When the Coordinator needs an Arena instance to select a game winner, it will send the Arena a Match. A match is Game but also includes the active roster (players) for both teams that will participate in the game.
**Org** | Bounded context (sub-module) dealing with overall organizational structure of a sports assocation.
**Pick** | Result event emitted when a player is automatically or manually selected.
**Player** | Identitiable as a person able to be drafted.  Meant to be subclassed and extended to include more intricate descriptions of a specific sport player, such as abilities, ratings, and statistics.  Right now it has none of these types of traits and it meant to only serve as the base with only an overall attribute.
**Record** | Represents a team's overall record.
**Regular** | Game that counts towards regular season record.
**Result** | The outcome of a game (typically with a home and away score).
**Room** | Main object responsible for providing an iterable interface capable of executing a draft, pick by pick.
**Scheduler** | Knows how to take a League and a year and generate a game-populated calendar.
**Scout** | Knows how to stack rank lists of players.
**Season** | Bounded context (sub-module) dealing with calendar and matchup generation.
**Skip** | Result event emitted when a front office decides to skip a round.
**Standings** | Synthesizes teams and results into team standings with win/loss records and more.
**Store** | Interface for the underlying Repository persistence layer.  While a Document Repository is mainly responsible for serialization/de-serialization, the store actually knows how to read/write the data.
**Team Group** | Set of rosters that together form a cohesive league.
**Team** | Member of a league and signs players.  Has games assigned and played.

### Installation

To install through Rubygems:

````
gem install basketball
````

You can also add this to your Gemfile using:

````
bundle add basketball
````

### Draft Module

The input for the main object `Basketball::Draft::Room` is an array of teams (`Basketball::Draft::FrontOffice`) and players (`Basketball::Org::Players`). Once instantiated there are four main methods:

* **Basketball::Draft::Room#sim!**: Simulate the next pick.
* **Basketball::Draft::Room#skip!**: Skip the next pick.
* **Basketball::Draft::Room#pick!(player)**: Pick an exact player for the current front office.
* **Basketball::Draft::Room#sim_rest!**: Simulate the rest of the picks.

### Season Module

The Season module knows how to execute a calendar of games for a League and generate results. The main object is the `Basketball::Season::Coordinator` class. Once instantiated there are four main methods:

* **Basketball::Season::Coordinator#sim!**: Simulate the next day of games.
* **Basketball::Season::Coordinator#sim_rest!**: Simulate the rest of the games.

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
