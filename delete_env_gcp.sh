#!/bin/bash

function set_variables(){
    CONFIG=$(awk -F "=" '/CONFIG/ {print $2}' ./src/config/configuration.ini)
    SVC_NAME=$(awk -F "=" '/SVC_NAME/ {print $2}' ./src/config/configuration.ini)
    PROJECT_ID=$(awk -F "=" '/PROJECT_ID/ {print $2}' ./src/config/configuration.ini)
    REGION=$(awk -F "=" '/REGION/ {print $2}' src/config/configuration.ini)
    ZONE=$(awk -F "=" '/ZONE/ {print $2}' ./src/config/configuration.ini)
}

function destroy_gcp_enviroment() {

    echo "-----------------------------------"
    echo "removendo artefatos no GCP, aguarde.."
    echo "-----------------------------------"

    gcloud config configurations activate default

    gcloud config configurations delete ${CONFIG} \
        --quiet

    gcloud projects delete ${PROJECT_ID} \
        --quiet

    rm -rf ./.private/account.json
}

function destroy_python_enviroment() {
    rm -rf ./boa_vista_env
}

if test -z "${GCP_ACCOUNT}"; then
  echo "ERRO: variável GCP_ACCOUNT não informada!"
  exit 1
fi

set_variables;
destroy_gcp_enviroment;
destroy_python_enviroment;