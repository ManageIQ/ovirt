# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.12.1] - 2016-08-17
### Bug Fixes
- Update minimum nokogiri version to resolve CVEs [#66]
- Allow fetching collections during targeted refresh [#65]
- Fix wrong error handling in rhevm infrastrcture provider [#63]
- Preserve boot order on Template clone [#61]

## [0.12.0] - 2016-08-09
### Breaking changes
- Ovirt::Inventory#collect_primary_targeted_jobs will no longer raise MissingResourceError [#62]

### Other changes
- Minimum Rest-client version of 2.0.0 [#60]

## [0.11.0] - 2016-07-07
### Breaking changes
- Drop support for Ruby 1.9.3 [#56]

### Other changes
- Remove "ovirt-engine" prefix from paths [#55]
- Drop dependency on ActiveSupport due to Rails 5 minimum Ruby version [#57]
