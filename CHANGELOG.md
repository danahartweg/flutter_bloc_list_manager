# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Added `OR` and `AND` modes for filtering
- Allow filter mode override for specific conditions

## [0.3.1] - 2020-08-08
### Fixed
- Corrected outdated `SearchQueryBloc` documentation

### Changed
- Updated `blocTest` and `whenListen` typing

## [0.3.0] - 2020-08-08
### Changed
- **Breaking:** `SearchQueryBloc` is now `SearchQueryCubit`
  - The `SetSearchQuery` event is now the `setQuery` method
  - The `ClearSearchQuery` event is now the `clearQuery` method

## [0.2.0] - 2020-07-28
### Added
- Changelog documentation

### Changed
- Abandoned Dart pre-1.0 semver designations. Bumping the package to account for the minor version bump that should have happened with the addition of boolean value support in 0.1.4.

## [0.1.5] - 2020-07-27
Previously released as 0.1.4+1

### Changed
- Bumped `bloc` to `^6.0.0`
- Bumped `flutter_bloc` to `^6.0.0`
- Bumped `bloc_test` to `^7.0.0`
- Updated testing code and added links to new documentation
- Moved over to the more accepted pre-1.0 semver designations

## [0.1.4] - 2020-07-26
### Added
- Boolean value support for automatic filter condition generation as well as while filtering the source list via https://github.com/danahartweg/flutter_bloc_list_manager/issues/8

## [0.1.3] - 2020-07-21
### Changed
- Bumped `bloc` to `^5.0.0`
- Bumped `flutter_bloc` to `^5.0.0`
- Bumped `bloc_test` to `^6.0.0`
- Updated bloc testing mechanisms to conform to the new `whenListen` behavior that also stubs the state when called: https://github.com/felangel/bloc/pull/1133

## [0.1.2] - 2020-04-24
### Changed
- Bumped `bloc` to `^4.0.0`
- Bumped `flutter_bloc` to `^4.0.0`
- Bumped `bloc_test` to `^5.0.0`

## [0.1.1] - 2020-04-12
### Changed
- Documentation updates

## [0.1.0] - 2020-04-12
Initial package implementation and testing.

### Added
- Introduced `ListManager`
- Introduced `FilterConditionsBloc`
- Introduced `SearchQueryBloc`
- Introduced `ItemListBloc`
- Added `ItemClassWithAccessor` and `ItemSourceState` to manage
