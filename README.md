# Basketball

[![Gem Version](https://badge.fury.io/rb/basketball.svg)](https://badge.fury.io/rb/basketball) [![CI](https://github.com/mattruggio/basketball/actions/workflows/ci.yaml/badge.svg)](https://github.com/mattruggio/basketball/actions/workflows/ci.yaml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

:warning: **Note:** This is currently in the early phases of initial development. Consider all < 1 releases as having unstable APIs between versions. A formal 1.0.0 major release will be eventually released which will honor [Semver](https://semver.org/).

This library is meant to serve as the domain for a basketball league/season simulator/turn-based game. It models core ideas such as: players, general managers, draft strategy, drafting, season generation, season simultation, playoff generation, playoff simulation, and more.

![Architecture](/docs/architecture.png)

Element      | Description
:------------ | :-----------
**Arena** | Determines exhibition and regular season game outcomes.
**Assessment** | When the Room needs to know who a Front Office wants to select, the Room will send the Front Office an Assessment. The Assessment is a report of where the team currently stands: players picked, players available, and round information.
**basketball-draft-room** | Command-line executable script showing an example of how to consume the draft room aggregate root.
**basketball-season-coordinator** | Command-line executable script showing an example of how to consume the season coordinator aggregate root.
**Calendar** | Stores important boundary dates (exhibition start, exhibition end, season start, and season end).
**Conference** | A collection of Divisions.
**Coordinator CLI** | Underlying Ruby class that powers the `basketball-season-coordinator` script. Basically a terminal wrapper over the Coordinator object.
**Coordinator Repository** | Understands how to save and load Coordinator objects from JSON files on disk.
**Coordinator** | Object which can take a League, Calendar, Games, and an Arena and provide an iterable interface to enumerate through days and simulate games as results.
**Detail** | Re-representation of a Result object but from a specific team's perspective.
**Division** | A collection of teams.
**Draft** | Bounded context (sub-module) dealing with running a round-robin player draft for teams.
**Exhibition** | Pre-season game which has no impact to team record.
**External Dependency** | Some outside system which this library or portions of this library are dependent on.
**File Store** | Implements a store that can interact with the underlying File System.
**File System** | Local operating system that the CLI will use for persistence.
**Front Office** | Identifiable as a team, contains logic for how to auto-pick draft selections.  Meant to be subclassed and extended to include more intricate player selection logic as the base will simply randomly select a player.
**Game** | Matches up a date with two teams (home and away) to represent a coordinatord match-up.
**League Repository** | Understands how to save and load League objects from JSON files on disk.
**League** | Describes a league in terms of structure composed of conferences, divisions, teams, and players.
**Match** | When the Coordinator needs an Arena instance to select a game winner, it will send the Arena a Match. A match is Game but also includes the active roster (players) for both teams that will participate in the game.
**Org** | Bounded context (sub-module) dealing with overall organizational structure of a sports assocation.
**Pick** | Result event emitted when a player is automatically or manually selected.
**Player** | Identitiable as a person able to be drafted.  Meant to be subclassed and extended to include more intricate descriptions of a specific sport player, such as abilities, ratings, and statistics.  Right now it has none of these types of traits and it meant to only serve as the base with only an overall attribute.
**Record** | Represents a team's overall record.
**Regular** | Game that counts towards regular season record.
**Result** | The outcome of a game (typically with a home and away score).
**Room CLI** | Underlying Ruby class that powers the `basketball-draft-room` script. Basically a terminal wrapper for the Room object.
**Room Repository** | Understands how to save and load Room objects from JSON files on disk.
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

#### Command Line Interface

This library ships with an example of how the Draft module could be used implemented as a command-line executable script. The script is file-based and will de-serialize into a Room object, execute operations, then serialize and write it back to disk.

###### Generate a Fresh Draft

```zsh
basketball-draft-room -o tmp/draft.json
```

###### N Top Available Players

```zsh
basketball-draft-room -i tmp/draft.json -t 10
```

###### N Top Available Players for a Position

```zsh
basketball-draft-room -i tmp/draft.json -t 10 -q PG
```

###### Output League

```zsh
basketball-draft-room -i tmp/draft.json -l
```

###### Output Event Log

```zsh
basketball-draft-room -i tmp/draft.json -e
```

###### Simulate N Picks

```zsh
basketball-draft-room -i tmp/draft.json -s 10
```

###### Skip N Picks

```zsh
basketball-draft-room -i tmp/draft.json -x 10
```

###### Pick Players

```zsh
basketball-draft-room -i tmp/draft.json -p P-100,P-200,P-300
```

###### Simulate the Rest of the Draft

```zsh
basketball-draft-room -i tmp/draft.json -a
```

###### Help Menu

```zsh
basketball-draft-room -h
```

### Season Module

The Season module knows how to execute a calendar of games for a League and generate results. The main object is the `Basketball::Season::Coordinator` class. Once instantiated there are four main methods:

* **Basketball::Season::Coordinator#sim!**: Simulate the next day of games.
* **Basketball::Season::Coordinator#sim_rest!**: Simulate the rest of the games.

#### Command Line Interface

This library ships with an example of how the Season module could be used implemented as a command-line executable script.  The script is file-based and will de-serialize into a Coordinator object, execute operations, then serialize and write it back to disk.

###### Generate Random coordinator

```zsh
exe/basketball-season-coordinator -o tmp/coordinator.json
```

###### Sim One Day and Save to New File

```zsh
exe/basketball-season-coordinator -i tmp/coordinator.json -o tmp/coordinator2.json -d 1
```

###### Output Event Log

```zsh
exe/basketball-season-coordinator -i tmp/coordinator.json -e
```

###### Sim Two Days and Save To Input File

```zsh
exe/basketball-season-coordinator -i tmp/coordinator.json -d 2
```

###### Sim Rest of Calendar

```zsh
exe/basketball-season-coordinator -i tmp/coordinator.json -a
```

###### Help Menu

```zsh
basketball-season-coordinator -h
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
