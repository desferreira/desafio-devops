
# Seções
- [Objetivo](#objetivo)
- [O que é criado pelo repositório](#o-que-é-criado-pelo-script)
- [Como correr o script](#como-correr-o-script)
- [Kubernetes](#kubernetes)

# Objetivo
Esse repositório tem como objetivo criar uma infraestrutura para uma empresa que deseja migrar o seu monolito para cloud. Nessa pasta `infra-as-code` existe dois arquivos principais: main.tf e o variables.tf, esses dois são responsáveis por criar toda a infraestrutura necessária para tal. A infraestrutura será criada na AWS.

# O que é criado pelo script

- VPC contendo 6 subnets, com 3 públicas e 3 privadas
- Uma VM
- Um bucket s3
- Um banco de dados RDS MySQL

A configuração do backend e frontend foi feita para eles rodarem numa mesma VM, utilizando docker. Logo, o acesso ao backend é feito através de `localhost:8080`, isso muda de figura se for usado o Kubernetes, que podemos utilizar apenas o service `letscode-backend-svc`. 

# Como correr o script
Existe na raiz do projeto um script chamado `deploy-code.sh`, basta correr ele com suas credenciais da AWS e ele deve criar toda a infraestrutura necessária, também faz output dos dados mais importantes: 

- URL do bucket
- URL do RDS
- IP da VM criada

Para destruir toda a infraestrutura, basta correr `destroy.sh`

# Kubernetes
Na pasta "manifests" estão os yamls necessários para fazer deploy da aplicação em Kubernetes, no script `infra-as-code/scripts/startup.sh` existe a instalação de uma distribuição Kubernetes local, o kind, com ela é possível executar os manifests e ter a aplicação também funcionando.

Existe também o `frontend.yml` e o `backend.yaml` que são responsáveis pelo deployment da aplicação, para isso funcionar é preciso alterar as credenciais de URL da DB, usuário e senha, isso pode ser configurado como secrets através de um configmap, utilizando o Vault, por exemplo. Ou isso ser injetado através de um servidor de CI/CD, como o Jenkins. São várias alternativas que deixei de fora desta demo por questão de tempo apertado.

