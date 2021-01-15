#!/bin/bash
function create_gcp_config_file(){

    echo "-----------------------------------"
    echo "criando arquivo de configuração gcp.."
    echo "-----------------------------------"

    > ./src/config/configuration.ini
    echo "[GCP]" >> ./src/config/configuration.ini
    echo "CONFIG=config-"$RANDOM  >> ./src/config/configuration.ini
    echo "SVC_NAME=svc-"$RANDOM  >> ./src/config/configuration.ini
    echo "PROJECT_ID=gcp-boavista-"$RANDOM  >> ./src/config/configuration.ini
    echo "REGION=southamerica-east1"  >> ./src/config/configuration.ini
    echo "ZONE=southamerica-east1-a"  >> ./src/config/configuration.ini
    echo "DATASET=raw"  >> ./src/config/configuration.ini
}

function set_env_vars(){

    echo "-----------------------------------"
    echo "criando variavel de ambiente.."
    echo "-----------------------------------"

    CONFIG=$(awk -F "=" '/CONFIG/ {print $2}' ./src/config/configuration.ini)
    SVC_NAME=$(awk -F "=" '/SVC_NAME/ {print $2}' ./src/config/configuration.ini)
    PROJECT_ID=$(awk -F "=" '/PROJECT_ID/ {print $2}' ./src/config/configuration.ini)
    REGION=$(awk -F "=" '/REGION/ {print $2}' src/config/configuration.ini)
    ZONE=$(awk -F "=" '/ZONE/ {print $2}' ./src/config/configuration.ini)
}

function build_gcp_enviroment() {

    echo "-----------------------------------"
    echo "construindo configuração no GCP, aguarde.."
    echo "-----------------------------------"

    gcloud config configurations create ${CONFIG}
    gcloud config configurations activate ${CONFIG}

    echo "-----------------------------------"
    echo "configurando zona, region project e account.. "
    echo "-----------------------------------"

    gcloud config set compute/zone ${ZONE}
    gcloud config set compute/region ${REGION}
    gcloud config set project ${PROJECT_ID}
    gcloud config set account ${GCP_ACCOUNT}

    gcloud projects create ${PROJECT_ID} \
        --quiet

    gcloud iam service-accounts create ${SVC_NAME} \
        --display-name ${SVC_NAME} \
        --quiet

    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member serviceAccount:${SVC_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
        --role roles/owner \
        --quiet

    gcloud iam service-accounts keys create .private/account.json \
        --iam-account=${SVC_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
        --quiet

    export GOOGLE_APPLICATION_CREDENTIALS="./.private/account.json"

}

function replace_schema_sql() {
    mkdir ./raw_data/tmp
    cp ./raw_data/views/vw_fact_bill_of_materials.sql ./raw_data/tmp/vw_fact_bill_of_materials.sql
    cp ./raw_data/views/vw_fact_bracket_pricing.sql ./raw_data/tmp/vw_fact_bracket_pricing.sql
    cp ./raw_data/views/vw_fact_non_bracket_pricing.sql ./raw_data/tmp/vw_fact_non_bracket_pricing.sql
    rpl "<schema_aqui>" ${PROJECT_ID} ./raw_data/tmp/vw_fact_bill_of_materials.sql
    rpl "<schema_aqui>" ${PROJECT_ID} ./raw_data/tmp/vw_fact_bracket_pricing.sql
    rpl "<schema_aqui>" ${PROJECT_ID} ./raw_data/tmp/vw_fact_non_bracket_pricing.sql
}

function build_venv() {

    echo "-----------------------------------"
    echo "inicializando o ambiente, aguarde..."
    echo "-----------------------------------"

    pip install virtualenv
    virtualenv boa_vista_env

    ./boa_vista_env/bin/activate
    ./boa_vista_env/bin/pip3 install configparser
    ./boa_vista_env/bin/pip3 install google.oauth2
    ./boa_vista_env/bin/pip3 install google-cloud-bigquery
}

function run_pipeline() {
    echo "-----------------------------------"
    echo "pipeline em execucao , aguarde..."
    echo "-----------------------------------"

    ./boa_vista_env/bin/python3 src/main.py

    rm ./raw_data/tmp/*
}

if test -z ${GCP_ACCOUNT}; then
  echo "ERRO: Informe a variavel GCP_ACCOUNT!"
  exit 1
fi

create_gcp_config_file;
set_env_vars;
build_gcp_enviroment;
replace_schema_sql;
build_venv;
sleep 3
run_pipeline;