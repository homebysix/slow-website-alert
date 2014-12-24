Slow Website Alert Changelog
============================

Version 1.0.2 - 2014-12-23

- Response time is now the average of three `curl` tests.
- Now includes timestamp in Terminal Notifier alerts.
- Using functions for log output.
- Minor changes based on shell script linter feedback.

Version 1.0.1 - 2014-12-04

- Created change log (this file).
- Added check to ensure DEBUG_MODE is set to either true or false.
- Disabled MAX_TIME and TEST_FREQ verification if DEBUG_MODE is true.
- Added group ID to Terminal Notifier alerts.
- Log output now includes hostname of computer running the script.

Version 1.0 - 2014-12-03

- Initial public release.