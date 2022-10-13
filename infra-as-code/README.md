
# Seções
1. 
2.
3.

# Objetivo
Esse repositório tem como objetivo criar uma infraestrutura para uma empresa que deseja migrar o seu monolito para cloud. Nessa pasta `infra-as-code` existe dois arquivos principais: main.tf e o variables.tf, esses dois são responsáveis por criar toda a infraestrutura necessária para tal. A infraestrutura será criada na AWS.

# O que é criado pelo script

- VPC contendo 6 subnets, com 3 públicas e 3 privadas
- Uma VM
- Um bucket s3
- Um banco de dados RDS MySQL

# Como correr o script
Existe na raiz do projeto um script chamado `deploy-code.sh`, basta correr ele com suas credenciais da AWS e ele deve criar toda a infraestrutura necessária, também faz output dos dados mais importantes: 

- URL do bucket
- URL do RDS
- IP da VM criada

Para destruir toda a infraestrutura, basta correr `destroy.sh`