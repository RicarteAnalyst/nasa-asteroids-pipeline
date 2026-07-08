from airflow import DAG
from airflow.decorators import dag, task
from datetime import datetime
import requests
import pandas as pd
from airflow.providers.postgres.hooks.postgres import PostgresHook
import os
from dotenv import load_dotenv
import pandas as pd

basedir = os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../.env"))

with DAG(
    dag_id='monitor_nasa_asteroides',
    schedule='@daily',
    start_date=datetime(2025, 6, 1),
    catchup=True,
    max_active_runs=1
) as dag:

    @task
    def extrair_dados(**kwargs):
        url_base = os.getenv('URL')
        api_key = os.getenv('API_KEY')

        

        execution_date = kwargs['execution_date']

        data_str = execution_date.strftime('%Y-%m-%d')


        params = {
            "api_key": api_key,
            "start_date": data_str,
            "end_date": data_str
        }

        response = requests.get(url_base, params=params)
        response.raise_for_status()
        return response.json()

    @task
    def load(dados_json):
        hook = PostgresHook(postgres_conn_id='postgres_default')
        
        sql_create = """
        CREATE TABLE IF NOT EXISTS raw_nasa_asteroides(
            nome TEXT,
            diametro_max_km FLOAT,
            is_perigoso BOOLEAN,
            data_observacao DATE
        );
        """
        hook.run(sql_create)

        datas_disponiveis = list(dados_json['near_earth_objects'].keys())
        if not datas_disponiveis:
            return
        primeira_data = datas_disponiveis[0]


        sql_delete = "DELETE FROM raw_nasa_asteroides WHERE data_observacao = %s"
        hook.run(sql_delete, parameters=(primeira_data,))

        print(f"Limpeza concluída para a data {primeira_data}")


        # Acessando os dados do dicionário da NASA
        asteroides = dados_json['near_earth_objects'][primeira_data]
        rows = []
        for asteroide in asteroides:
            nome = asteroide['name']
            diametro = asteroide['estimated_diameter']['kilometers']['estimated_diameter_max']
            perigo = asteroide['is_potentially_hazardous_asteroid']
            rows.append((nome, diametro, perigo, primeira_data))

        hook.insert_rows(
            table='raw_nasa_asteroides',
            rows=rows,
            target_fields=['nome', 'diametro_max_km', 'is_perigoso', 'data_observacao'])

    # Fluxo de execução (Orquestração)
    dados = extrair_dados()
    load(dados)
    