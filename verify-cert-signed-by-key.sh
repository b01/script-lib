#!/bin/sh

# To verify that an OpenSSL certificate was signed by a specific private key,
# you can extract the public key from both the certificate and the private key
# and compare their MD5 hashes. If the hashes match, it indicates the
# certificate was likely signed by that private key.

set -e

certificate="${1}"
key="${2}"

echo "Extracting the public key from the certificate"
certificate_public_key=$(openssl x509 -in "${certificate}" -pubkey -noout)

echo "Extracting the public key from the private key"
key_public_key=$(openssl pkey -in "${key}" -pubout)

echo "Calculate the MD5 hash of both public keys"
md5_certificate_public_key=$(openssl x509 -in "${certificate}" -pubkey -noout | openssl md5)
md5_key_public_key=$(openssl pkey -in "${key}" -pubout | openssl md5)

# If the MD5 hashes of the public keys extracted from the certificate and the
# private key are identical, it suggests that the certificate was likely signed
# by that private key.

echo "Comparing the MD5 hashes:"
echo "${certificate} MD5 hash = ${md5_certificate_public_key}"
echo "${key} MD5 hash = ${md5_key_public_key}"
if [ "${md5_certificate_public_key}" = "${md5_key_public_key}" ]
then
    echo "the certificate was likely signed by that private key."
else
    echo "hashes do not match; the certificate was not likely signed by the key."
fi
