#### 0.0.4 - May 5th, 2023

* Add ability to skip draft picks using `Basketball::Drafting::Engine#skip!`
* Add ability to output event full drafting event log using CLI: `basketball-draft -i tmp/draft-wip.json -l`
* Add ability to skip draft picks using CLI: `basketball-draft -i tmp/draft-wip.json -x 1`

#### 0.0.3 - May 5th, 2023

* `Drafting::Engine#sim!` should return events
* Added `Drafting::Engine#undrafted_player_search`

#### 0.0.2 - May 4th, 2023

* Remove autoloading in favor of require statements.

#### 0.0.1 - May 4th, 2023

* Initial release with Drafting module only
