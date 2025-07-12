# Function to check AWS SSO login status
function Check-AwsSsoLogin {
    param (
        [string]$profileName
    )

    # Attempt to retrieve the AWS account ID using sts get-caller-identity
    $output = aws sts get-caller-identity --profile "${profileName}" --output json 2>&1

    if (${LASTEXITCODE} -ne 0) {
        switch -Wildcard (${output}) {
            ("*ExpiredToken*") { Write-Host "AWS SSO token has expired. Please renew your login using 'aws sso login'." }
            ("*does not exist*") { Write-Host "AWS profile credentials could not be found." }
            default { Write-Host "An error occurred. Please manually login using 'aws sso login'." }
        }

        return  "no"
    }

    $arn = (${output} | ConvertFrom-Json).Arn
    Write-Host "currently logged in as ${arn}"
    return "yes"
}

# Determine profile
$profile = "${env:AWS_PROFILE}"

if ($args.Count -gt 0) {
    $profile = $args[0]
}

if ([string]::IsNullOrEmpty($profile)) {
    Write-Host "Missing AWS profile, pass it in as the first argument or set AWS_PROFILE."
}

$logged_in = Check-AwsSsoLogin -profileName "${profile}"

if ($logged_in -eq "no") {
    Write-Host "logging in..."
    aws sso login --use-device-code 2>&1
    if (${LASTEXITCODE} -ne 0) {
        Write-Host "failed auto AWS sso login."
    } else {
        Write-Host "done."
    }
}
