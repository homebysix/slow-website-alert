Slow Website Alert Change Log
=============================

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
### Fixed
- Fixed typo that resulted in incorrect email formatting.
### Changed
- Switched change log to [standard format](http://keepachangelog.com/).

## [1.0.2] - 2014-12-23
### Changed
- Response time is now the average of three `curl` tests.
- Now includes timestamp in Terminal Notifier alerts.
- Using functions for log output.
- Minor changes based on shell script linter feedback.

## [1.0.1] - 2014-12-04
### Added
- Created change log (this file).
- Added check to ensure DEBUG_MODE is set to either true or false.
- Added group ID to Terminal Notifier alerts.
- Log output now includes hostname of computer running the script.
### Fixed
- Disabled MAX_TIME and TEST_FREQ verification if DEBUG_MODE is true.

## 1.0 - 2014-12-03
### Added
- Initial public release.

[unreleased]: https://github.com/homebysix/slow-website-alert/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/homebysix/slow-website-alert/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/homebysix/slow-website-alert/compare/v1.0...v1.0.1