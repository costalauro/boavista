import os
import json
import logging
from pathlib import Path
from google.cloud import bigquery
from google.cloud.bigquery.schema import SchemaField
from google.cloud.bigquery.job import LoadJobConfig

TABLES_DIR = os.getcwd() + "/raw_data/tables/"
SCHEMA_DIR = os.getcwd() + "/raw_data/schemas/"


class TableManager():

    def __init__(self, client, dataset_id):
        self.client = client
        self.dataset_id = dataset_id

    def get_table_names(self):
        return [
            p.stem
            for p in Path(TABLES_DIR).glob("*.csv")
        ]

    def get_table_file(self, table_name):
        return (Path(TABLES_DIR).joinpath("%s.csv" % table_name))

    def get_table_schema_file(self, table_name):
        return Path(SCHEMA_DIR).joinpath("%s_schema.json" % table_name)

    def get_table_schema(self, schema_file):
        with open(schema_file) as json_file:
            data = json.load(json_file)
            schema = [SchemaField.from_api_repr(json_field) for json_field in data]
            return schema

    def update_or_create_table_from_csv(self, table_name, table_file, schema_file):
        dataset_ref = self.client.dataset(self.dataset_id)
        table_ref = dataset_ref.table(table_name)

        job_config = LoadJobConfig()
        job_config.source_format = "CSV"
        job_config.skip_leading_rows = 1
        if Path(schema_file).exists():
            job_config.schema = self.get_table_schema(schema_file)
        else:
            job_config.autodetect = True
        job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE

        with open(table_file, "rb") as source_fp:
            load_job = self.client.load_table_from_file(
                source_fp,
                destination=table_ref,
                job_config=job_config
            )

        load_job.result()
        logging.info("tabela [%s] criada com sucesso", table_ref.table_id)

    def update_or_create_tables(self):
        logging.info("iniciando o processamento das tabelas")
        table_names = self.get_table_names()
        for table_name in table_names:
            self.update_or_create_table_from_csv(
                table_name,
                self.get_table_file(table_name),
                self.get_table_schema_file(table_name)
            )
