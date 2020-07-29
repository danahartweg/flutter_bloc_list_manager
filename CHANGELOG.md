# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.4+2] - 2020-07-28
### Added
- Changelog documentation

## [0.1.4+1] - 2020-07-27

+ Bumped `bloc` to `^6.0.0`
+ Bumped `flutter_bloc` to `^6.0.0`
+ Bumped `bloc_test` to `^7.0.0`

Updated testing code and added links to new documentation. Moved over to the more accepted pre-1.0 semver designations.

## [0.1.4] - 2020-07-26

Adds boolean value support for automatic filter condition generation as well as while filtering the source list.

Closes https://github.com/danahartweg/flutter_bloc_list_manager/issues/8

## [0.1.3] - 2020-07-21

+ Bumped `bloc` to `^5.0.0`
+ Bumped `flutter_bloc` to `^5.0.0`
+ Bumped `bloc_test` to `^6.0.0`

Updated bloc testing mechanisms to conform to the new `whenListen` behavior that also stubs the state when called: https://github.com/felangel/bloc/pull/1133

## [0.1.2] - 2020-04-24

+ Bumped `bloc` to `^4.0.0`
+ Bumped `flutter_bloc` to `^4.0.0`
+ Bumped `bloc_test` to `^5.0.0`

## [0.1.1] - 2020-04-12

Documentation updates.

## [0.1.0] - 2020-04-12

Initial package implementation and testing.

+ Introduced `ListManager`
+ Introduced `FilterConditionsBloc`
+ Introduced `SearchQueryBloc`
+ Introduced `ItemListBloc`
+ Added `ItemClassWithAccessor` and `ItemSourceState` to manage state
