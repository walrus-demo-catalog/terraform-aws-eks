export WALRUS_URL=${WALRUS_URL}
export WALRUS_TOKEN=${WALRUS_TOKEN}
export ARCH=${ARCN}
export OS=${OS}
export K8S_CONNECTOR_NAME=${K8S_CONNECTOR_NAME}
export ENV_TYPE=${ENV_TYPE}

export CLUSTER_ARN=${CLUSTER_ARN}
export CLUSTER_ENDPOINT=${CLUSTER_ENDPOINT}
export CLUSTER_CERTIFICATE_AUTHORITY_DATA=${CLUSTER_CERTIFICATE_AUTHORITY_DATA}
export CLUSTER_TOKEN=${CLUSTER_TOKEN}

cat <<EOF > kubeconfig.temp
apiVersion: v1
clusters:
- cluster:
    server: ${CLUSTER_ENDPOINT}
    certificate-authority-data: ${CLUSTER_CERTIFICATE_AUTHORITY_DATA}
  name: ${CLUSTER_ARN}
contexts:
- context:
    cluster: ${CLUSTER_ARN}
    user: ${CLUSTER_ARN}
  name: ${CLUSTER_ARN}
current-context: ${CLUSTER_ARN}
kind: Config
preferences: {}
users:
- name: ${CLUSTER_ARN}
  user:
    token: ${CLUSTER_TOKEN}
EOF

awk '{printf "%s\\n", $0}' kubeconfig.temp > kubeconfig
(
printf "%s" 'walrus connector create -d --name ${K8S_CONNECTOR_NAME} --applicable-environment-type ${ENV_TYPE} --type Kubernetes --category Kubernetes --project="" --config-version v1 --config-data='"'"'{"kubeconfig":{"visible":false,"value":"'
cat kubeconfig
echo '","type":"string"}}'"'"''
) > create_walrus_connector.sh
(
printf "%s" 'walrus connector update ${K8S_CONNECTOR_NAME} -d --type Kubernetes --category Kubernetes --project="" --config-version v1 --config-data='"'"'{"kubeconfig":{"visible":false,"value":"'
cat kubeconfig
echo '","type":"string"}}'"'"''
) > update_walrus_connector.sh

wget -O /usr/local/bin/walrus --no-check-certificate "${WALRUS_URL}/cli?arch=${ARCN}&os=${OS}"
chmod +x /usr/local/bin/walrus
walrus login --insecure --server ${WALRUS_URL} --api-key ${WALRUS_TOKEN}
walrus version

/bin/sh create_walrus_connector.sh
/bin/sh update_walrus_connector.sh
