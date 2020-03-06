#!/bin/bash
apt-get update
apt-get install -y unzip wget

cd /tmp

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i /tmp/amazon-cloudwatch-agent.deb

echo '
    {
        "logs": {
            "logs_collected": {
                "files": {
                    "collect_list": [
                        {
                            "file_path": "/var/log/vault_audit.log",
                            "log_group_name": "${cloudwatch_log_group}",
                            "log_stream_name": "{instance_id}"
                        }
                    ]
                }
            }
        }
    }
' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
/opt/consul/bin/run-consul --client --cluster-tag-key consul-cluster --cluster-tag-value consul-cluster-example

wget https://releases.hashicorp.com/vault/1.3.2/vault_1.3.2_linux_amd64.zip
unzip vault_1.3.2_linux_amd64.zip

mv /tmp/vault /usr/local/bin/

mkdir /etc/vault/

echo '
    storage "consul" {
        address = "127.0.0.1:8500"
        path    = "vault"
    }

    listener "tcp" {
        address     = "127.0.0.1:8200"
        tls_disable = 1
    }

    seal "awskms" {
        region = "${region}"
        kms_key_id = "${kms_key_id}"
    }
' > /etc/vault/config.hcl

echo '{
    "service": {
        "name": "vault",
        "tags": ["vault"],
        "port": 8200,
        "check": {
            "id": "vault_check",
            "name": "Check vault health",
            "service_id": "vault",
            "http": "http://localhost:8200/",
            "method": "GET",
            "interval": "10s",
            "timeout": "1s"
        }
    }
}' > /opt/consul/config/vault.json

consul reload

useradd --system vault
touch /var/log/vault_audit.log
chown vault:vault /var/log/vault_audit.log

echo '
[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config /etc/vault/config.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536
' > /etc/systemd/system/vault.service

service vault start

sleep 30

export VAULT_ADDR=http://127.0.0.1:8200

if [[ $(vault status -format json | jq -r .initialized) == "false" ]]
then
    apt install -y python3-pip
    pip3 install awscli --upgrade --user

    output=$(vault operator init -recovery-shares=1 -recovery-threshold=1 -format json -recovery-pgp-keys="keybase:${keybase_username}" -root-token-pgp-key="keybase:${keybase_username}")

    key=$(echo $output | jq -r .recovery_keys_b64)
    token=$(echo $output | jq -r .root_token)

    aws ssm put-parameter --name VaultRecoveryKey --value "$key" --type String --region ${region} --overwrite
    aws ssm put-parameter --name VaultRootToken --value "$token" --type String --region ${region} --overwrite

    vault login $token

    vault audit enable file file_path=/var/log/vault_audit.log

    ${install_vault_ca}
fi
