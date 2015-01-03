#!/bin/bash

###
#
#            Name:  slow_website_alert.sh
#     Description:  This script is intended to run in the background and check
#                   the speed of a set of websites. If any of the sites are
#                   slower than a specific threshold, the script sends an alert.
#          Author:  Elliot Jordan <elliot@elliotjordan.com>
#         Created:  2014-12-02
#   Last Modified:  2014-12-20
#         Version:  1.0.3
#
###


############################### WEBSITE SETTINGS ###############################

# The URL of your website(s).
# Must include http(s):// and trailing slash, if required to avoid redirects.
URL=(
    "http://www.pretendco.com/"
    "http://www.pretendco.com/blog"
    "http://store.pretendco.com"
)

# The name of the log file to which speed results will be saved. By default,
# this is the name of this script with .log extension.
LOG_FILE="$(basename "$0" | sed 's/.sh/.log/g')"


################################ ALERT SETTINGS ################################

# The website response time above which an email alert will be sent.
MAX_TIME=5.0

# Time between tests, in seconds. (3600 seconds = 1 hour)
TEST_FREQ=300

# The email notifications will be sent to this email address.
# Multiple "to" addresses can be separated by commas.
EMAIL_TO="you@pretendco.com, somebodyelse@pretendco.com"

# The email notifications will be sent from this email address.
EMAIL_FROM="$(whoami)@$(hostname)"

# The path to sendmail on your server. Typically /usr/sbin/sendmail.
sendmail="/usr/sbin/sendmail"

# Set to true if you have Terminal Notifier installed on this host.
# (https://github.com/alloy/terminal-notifier)
USE_TERMINAL_NOTIFIER=false

# Set to true if you want the script to display the email in standard output
# instead of actually sending it.
DEBUG_MODE=false


################################################################################
######################### DO NOT EDIT BELOW THIS LINE ##########################
################################################################################


################################## FUNCTIONS ###################################

# Log functions
APPNAME=$(basename "$0" | sed "s/\.sh$//")
fn_log_info() {
    echo "$(date) : $APPNAME : $1" >> "$LOG_FILE"
}
fn_log_debug() {
    echo "$(date) : $APPNAME : [DEBUG] $1" >> "$LOG_FILE"
}
fn_log_warn() {
    echo "$(date) : $APPNAME : [WARNING] $1" >> "$LOG_FILE"
}
fn_log_error() {
    echo "$(date) : $APPNAME : [ERROR] $1" >> "$LOG_FILE"
}


######################## VALIDATION AND ERROR CHECKING #########################

# Let's make sure we aren't using default email alert settings.
if [[ $EMAIL_TO == "you@pretendco.com, somebodyelse@pretendco.com" ]]; then

    fn_log_error "The email alert settings are still set to the default value. Please edit them to suit your environment."
    exit 1001

fi # End email alert settings validation.

# Let's make sure the sendmail path is correct.
if [[ ! -x "$sendmail" ]]; then

    fn_log_warn "The specified path to sendmail ($sendmail) appears to be incorrect. Trying to locate the correct path..."
    sendmail_try2=$(which sendmail)

    if [[ $sendmail_try2 == '' || ! -x $sendmail_try2 ]]; then
        fn_log_error "Unable to locate the path to sendmail."
        exit 1002
    else
        fn_log_warn "Located sendmail at $sendmail_try2. Please adjust the $APPNAME script settings accordingly."
        sendmail="$sendmail_try2"
        # Fatal error avoided. No exit needed.
    fi

fi # End sendmail validation.

# Let's make sure we're not running tests too quickly.
if (( $(bc <<< "$TEST_FREQ < 5") == 1 )); then
    if [[ $DEBUG_MODE == false ]]; then

        fn_log_error "It's not recommended to run tests less than 5 seconds apart."
        exit 1003

    fi
fi # End test frequency validation.

# Let's make sure Terminal Notifier is working, if we're configured to use it.
if [[ $USE_TERMINAL_NOTIFIER == true ]]; then
    
    notifier="$(which terminal-notifier)"

    if [[ "$notifier" == "" || ! -x "$notifier" ]]; then

        fn_log_error "Terminal Notifier is not installed or not executable."
        exit 1004

    fi

fi # End Terminal Notifier validation.

# Let's make sure MAX_TIME is set to a reasonable value.
if (( $(bc <<< "$MAX_TIME > 60") == 1 ||
      $(bc <<< "$MAX_TIME < 2") == 1 )); then
    if [[ $DEBUG_MODE == false ]]; then

        fn_log_error "It's recommended to set a MAX_TIME between 2 seconds and 60 seconds."
        exit 1005

    fi
fi # End MAX_TIME validation.


################################# MAIN PROCESS #################################

# Count the number of sites we need to process.
SITE_COUNT=${#URL[@]}

# Let the user know how to stop the loop.
fn_log_info "Website speed tests have started. To stop, press Control-C."

# Begin looping.
while [[ true ]]; do

    # Begin iterating through websites.
    for (( i = 0; i < SITE_COUNT; i++ )); do

        TIME1=$(curl -s -w "%{time_total}" -o /dev/null "${URL[$i]}")
        TIME2=$(curl -s -w "%{time_total}" -o /dev/null "${URL[$i]}")
        TIME3=$(curl -s -w "%{time_total}" -o /dev/null "${URL[$i]}")
        AVG_TIME=$(bc <<< "scale=3; ( $TIME1 + $TIME2 + $TIME3 ) / 3")
        fn_log_info "$(date) : $(hostname) : ${URL[$i]} : $AVG_TIME seconds"

        if (( $(bc <<< "$AVG_TIME > $MAX_TIME") == 1 )); then
            fn_log_warn "Last result was greater than $MAX_TIME."
            
            # Construct an email.
            EMAIL_SUBJ="[${URL[$i]}] Website response greater than $MAX_TIME seconds"
            EMAIL_MSG="\nWARNING: The website located at ${URL[$i]} is taking longer than $MAX_TIME seconds to download.\n\n"
            EMAIL_MSG+="Latest log entry:\n$(tail -n 1 "$LOG_FILE")\n\n"
            EMAIL_MSG+="Thank you.\n\n"
            EMAIL_MSG+="\n\n"
            EMAIL_MSG+="(This is an automated message sent by the $APPNAME script running on $(hostname).)"

            THE_EMAIL="From: $EMAIL_FROM\nTo: $EMAIL_TO\nSubject: $EMAIL_SUBJ\n$EMAIL_MSG\n.\n"

            if [[ $DEBUG_MODE == true ]]; then
                # Print the message, if in debug mode.
                printf "\n$THE_EMAIL\n"
            elif [[ $DEBUG_MODE == false ]]; then
                
                # Send the message.
                printf "$THE_EMAIL" | $sendmail "$EMAIL_TO"

                # Send notification to Terminal.
                if [[ $USE_TERMINAL_NOTIFIER == true ]]; then
                    $notifier -message "$AVG_TIME seconds" -title "Slow website alert at $(date +%H:%M)" -subtitle "${URL[$i]}" -sound Sosumi -open "file://$(pwd)/$LOG_FILE" -group "$(date +%s)"
                fi

            else

                fn_log_error "DEBUG_MODE must be set to either \"true\" or \"false\"."
                exit 1011

            fi

        fi

    done # End iterating through websites.

sleep "$TEST_FREQ"

done # End looping.

exit $?