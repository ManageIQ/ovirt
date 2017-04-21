# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.16.0] - 2017-04-21
### Bug Fixes
- Fix handling of version 4.y in Vm.attach_payload [#80]

### Other changes
- Add VM FQDN to guest_info [#79]

## [0.15.1] - 2017-02-22
### Bug Fixes
- Prevent template[:os][:type] being overwritten [#78]

## [0.15.0] - 2017-02-21
### Breaking changes
- Drop support for Ruby 2.0 [#75]

### Other changes
- Allow connection to use CA Certificates [#77]
- Support parsing templates without an OS [#76]

## [0.14.0] - 2016-11-21
### Other changes
- Fix discovery of oVirt v4 [#69]
- Allow passing params to Base#update, Update Vm#memory & Vm#guaranteed in one call to Vm#update_memory [#72]
- Update event map [#71]

## [0.13.0] - 2016-08-23
### Breaking changes
- Ovirt::Inventory removed [#68]

### Other changes
- Add Host version parts [#67]

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
