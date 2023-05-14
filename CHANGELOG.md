#### 0.0.7 - May 14th, 2023

* Added #to_hash and #from_hash serializer methods to allow larger consumer json constructions more directly.
* Opt for string keys during serialization/deserialization.

#### 0.0.6 - May 11th, 2023

* Added Scheduling module that can generate full schedules for entire league.
* Draft::Event does not have identity anymore (no current tangible benefit).

#### 0.0.5 - May 5th, 2023

* Remove the notion of Team in favor of a flat front office.
#### 0.0.4 - May 5th, 2023

* Add ability to skip draft picks using `Basketball::Draft::Engine#skip!`
* Add ability to output event full draft event log using CLI: `basketball-draft -i tmp/draft-wip.json -l`
* Add ability to skip draft picks using CLI: `basketball-draft -i tmp/draft-wip.json -x 1`

#### 0.0.3 - May 5th, 2023

* `Draft::Engine#sim!` should return events
* Added `Draft::Engine#undrafted_player_search`

#### 0.0.2 - May 4th, 2023

* Remove autoloading in favor of require statements.

#### 0.0.1 - May 4th, 2023

* Initial release with Draft module only
