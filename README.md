# boavista
Este projeto resolve o problema proposto no processo seletivo da Boa Vista para Engenheiro de Dados: "modelar de forma eficaz os dados fornecidos, criar a infraestrutura e os artefatos necessários para carregar os arquivos e apresentar os resultados através de um dashboard."

## Decisões de arquitetura:

Google Cloud Plataform:

### BigQuery
  O BigQuery permite que as empresas façam uma análise em tempo real dos dados, usando parte de seu processamento potente para apresentar dados rapidamente para o usuário. Para isso, basta configurar a ferramenta da forma desejada e fazer com que ela acesse os dados em rede.

### Data Studio
  Com o Data Studio você consegue processar praticamente qualquer tipo de dado para criar relatórios personalizados, sem necessidade de dominar as linguagens de programação. ... – bancos de dados, como BigQuery, MySQL e PostgreSQL; – arquivos simples por meio do upload de arquivos CSV e Google Cloud Storage
 
## Pré-requisitos
> Python 3
> GCP SDK
> informar a variável do sistema GCP_ACCOUNT

## Execução do projeto:
Após seguir os pré-requisitos execute o comando: export GCP_ACCOUNT = "exemplo@domain.com", utilizando o seu e-mail,
em seguida execute o comando para montar o ambiente gcp:
```
git clone https://github.com/costalauro/boavista
cd boavista
./create_env_gcp.sh
```

Para excluir o ambiente execute:
```
./delete_env_gcp.sh
```

Os logs da operação podem ser visualizados no arquivo resultado.log localizado no diretório src\

## Modelo conceitual
Encontra-se na raiz do projeto.
