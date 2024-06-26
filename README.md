# danger-gem_changes

This is a [Danger](https://danger.systems/ruby/) plugin that can assist with
reviews involving Gemfile dependency changes. It can display a helpful table
with links to changelogs and diffs, and provides a DSL for evaluating changes
to your depdencies.

## Installation

```shell
$ gem install danger-gem_changes
```

## Usage

The following examples are changes to your Dangerfile.

### Summary Table

```ruby
# Print a markdown table summarizing Gemfile.lock changes, if any.
gem_changes.summarize_changes
```

> ### Gemfile.lock Changes
> | Gem | Source | Changelog | Change | Version | Level |
> | :-: | :----: | :-------: | :----: | :-----: | :---: |
> | [rubocop-factory_bot](https://rubygems.org/gems/rubocop-factory_bot) | [Source](https://github.com/rubocop/rubocop-factory_bot) | [Changelog](https://github.com/rubocop/rubocop-factory_bot/blob/master/CHANGELOG.md) | Downgraded | [2.25.1 ➘ 2.25.0](https://github.com/rubocop/rubocop-factory_bot/compare/v2.25.0...v2.25.1) | Patch |
> | [rubocop-performance](https://rubygems.org/gems/rubocop-performance) | [Source](https://github.com/rubocop/rubocop-performance) | [Changelog](https://github.com/rubocop/rubocop-performance/blob/master/CHANGELOG.md) | Added | 1.21.0 |  |
> | [rubocop-rake](https://rubygems.org/gems/rubocop-rake) | [Source](https://github.com/rubocop/rubocop-rake) | [Changelog](https://github.com/rubocop/rubocop-rake/blob/master/CHANGELOG.md) | Upgraded | [0.5.0 ➚ 0.6.0](https://github.com/rubocop/rubocop-rake/compare/v0.5.0...v0.6.0) | Minor |
> | [rubocop-rspec](https://rubygems.org/gems/rubocop-rspec) | [Source](https://github.com/rubocop/rubocop-rspec) | [Changelog](https://github.com/rubocop/rubocop-rspec/blob/master/CHANGELOG.md) | Removed | 2.29.2 |  |

### Changes DSL

This gem provides a DSL for accessing metadata about changes to your Gemfile dependencies:

| Method | Description |
| :----: | ----------- |
| `changes` | All dependency changes |
| `additions` | Dependencies that were not present before |
| `removals` | Dependencies that are no longer present |
| `upgrades` | Dependencies that have a newer version than before |
| `downgrades` | Dependencies that have a lower version than before |

Each dependency change has information about the gem and version change:

| Method | Example |
| :----: | ------- |
| `gem.name` | `rubocop-rake` |
| `from` | `0.6.0` |
| `to` | `0.6.1` |
| `change?` | `true` |
| `addition?` | `false` |
| `removal?` | `false` |
| `upgrade?` | `true` |
| `downgrade?` | `false` |

The `from` attribute will be nil for additions, and `to` will be nil for removals.

### More Examples

```ruby
# Print a warning if new dependencies were added.
warn "Dependencies added" if gem_changes.additions.any?
```

```ruby
# Print a table of dependency downgrades, if any
downgrades = gem_changes.downgrades
gem_changes.summarize_changes changes: downgrades, title: "Dependency Downgrades"
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
