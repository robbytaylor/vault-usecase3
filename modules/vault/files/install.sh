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
/usr/local/bin/vault server -config /etc/vault/config.hcl
vault audit enable file file_path=/var/log/vault_audit.log
