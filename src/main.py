import os
import time
import logging
import configparser
from datetime import datetime
from google.cloud import bigquery
from google.oauth2 import service_account
from manager.pipeline_manager import Pipeline


def set_credentials():

    key_path = os.getcwd() + "/.private/account.json"
    credentials = service_account.Credentials.from_service_account_file(
        key_path, scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    return credentials


def run():
    try:
        logging.info('início do processamento: %s', datetime.now())
        start = time.perf_counter()

        credentials = set_credentials()

        dataset_name = cfg['GCP']['DATASET']
        dataset_id = "{}.{}".format(cfg['GCP']['PROJECT_ID'], cfg['GCP']['DATASET'])

        client = bigquery.Client(credentials=credentials, project=credentials.project_id)
        pipeline_obj = Pipeline(client, dataset_id, dataset_name)
        pipeline_obj.initialize_pipeline()

        duration = time.perf_counter() - start
        logging.info('tempo de processamento: %s', duration)
        logging.info('fim do processamento: %s', datetime.now())
    except Exception as e:
        logging.info('erro: %s', str(e))


if __name__ == "__main__":
    cfg = configparser.ConfigParser()
    cfg.read(os.getcwd() + "/src/config/configuration.ini")
    logging.basicConfig(filename="resultado.log", level=logging.INFO, filemode='w')
    run()