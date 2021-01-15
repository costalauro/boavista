import logging
from google.cloud import bigquery


class DatasetManager:

    def __init__(self, client, dataset_id):
        self.client = client
        self.dataset_id = dataset_id

    def create_dataset(self):
        try:
            self.client.get_dataset(self.dataset_id)
            logging.info('[%s] já existe...', self.dataset_id)
        except:
            dataset = bigquery.Dataset(self.dataset_id)
            dataset = self.client.create_dataset(self.dataset_id, timeout=30)
            logging.info('dataset [%s] criado com sucesso', self.dataset_id)
