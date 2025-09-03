# Function to backup GPG Keys to a directory.
# You specify the the following parameters:
# Key UID
# A prefix name you choose
# Drive letter
# Optional root directory to place all keys in. Default is gpg-backup
#
# For example backup_gpg_key "0000000000000000" "crowbarjones" "D"
function backup_gpg_key {
    param (
        [Parameter(Mandatory)]
        [string]$KeyUID,
        [string]$PrefixName,
        [string]$DL,
        [string]$BackupDir="gpg-backup"
    )

    Write-Output "baking up GPG Key ${KeyUID} AS ${PrefixName}"

    if (!(Test-Path -Path ${DL}:\${BackupDir}\${PrefixName})) {
        mkdir -p ${DL}:\${BackupDir}\${PrefixName}
    }

    cd ${DL}:\${BackupDir}\${PrefixName}

    gpg --export --armor "${KeyUID}" > "${PrefixName}.public.asc"
    gpg --export-secret-keys --armor "${KeyUID}" > "${PrefixName}.private.asc"
    gpg --export-secret-subkeys --armor "${KeyUID}" > "${PrefixName}.sub_private.asc"
    cd ${DL}:\${BackupDir}
}
