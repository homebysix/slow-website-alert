Slow Website Alert
==================

This script is intended to run in the background and check the speed of a set of websites. If any of the sites are slower than a specific threshold, the script sends an alert.


## Features

- Configurable test frequency.
- Configurable speed threshold.
- Supports checking multiple websites in a batch.
- Supports both email alerts (using sendmail) and Terminal Notifier for Mac.


## Instructions

1. Edit the options in the WEBSITE SETTINGS and ALERT SETTINGS sections to suit your environment.
2. Run the script: `./path/to/slow_website_alert.sh`
   You will receive notifications if a site's download time exceeds the MAX_TIME threshold.
   You can monitor the `slow_website_alert.log` file for details.
3. Press Control-C to stop the script.


## Known Issues

- Does not work in a default OS X environment because sendmail is not configured.
- Pressing Control-C to stop the script isn't as elegant as it could be.


## To Do / Roadmap

- Fix known issues above.
- Ability to test alerts easily.
- Make compatible with cron.