vault secrets enable -path=ssh-client-signer ssh
vault write ssh-client-signer/config/ca generate_signing_key=true

public_key=$(vault read -field=public_key ssh-client-signer/config/ca)
aws ssm put-parameter --name VaultSSHPublicKey --value "$public_key" --type String --region ${region} --overwrite

vault write ssh-client-signer/roles/my-role -<<"EOH"
{
  "allow_user_certificates": true,
  "allowed_users": "*",
  "default_extensions": [
    {
      "permit-pty": ""
    }
  ],
  "key_type": "ca",
  "default_user": "ubuntu",
  "ttl": "30m0s"
}
EOH