#!/bin/sh

logged_in=""

# Function to check AWS SSO login status
check_aws_sso_login() {
    profile_name="${1}"

    # Attempt to retrieve the AWS account ID using sts get-caller-identity
    output="$(aws sts get-caller-identity --profile "${profile_name}" 2>&1)"

    if [ "${?}" -ne 0 ]; then
        case "${output}" in
            *ExpiredToken*)
                echo "AWS SSO token has expired. Please renew your login using 'aws sso login'."
                ;;
            *does not exist*)
                echo "AWS profile credentials could not be found."
                ;;
            *)
                echo "An error occurred. Please manually login using 'aws sso login'."
                ;;
        esac
        logged_in="no"
    else
        arn=$(echo "${output}" | awk -F'"' '/Arn/ {print $4}')
        echo "Successfully logged in as ${arn}"
        logged_in="yes"
    fi
}

profile="${AWS_PROFILE}"

if [ -n "${1}" ]; then
  profile="${1}"
fi

if [ -z "${profile}" ]; then
    echo "missing AWS profile, pass in as the first argument or set AWS_PROFILES"
fi

check_aws_sso_login "${profile}"

if [ "${logged_in}" = "no" ]; then
    aws sso login --use-device-code
    check_aws_sso_login "${profile}"
fi
