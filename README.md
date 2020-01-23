# CI/CD com AWS e Terraform - Infraestrutura pronta para produção

[![N|Solid](https://miro.medium.com/max/1568/1*DqldXuoO53SQrT137Op4IQ.png)](https://www.linkedin.com/in/alysonfranklin/)

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://www.linkedin.com/in/alysonfranklin/)

Este código foi criado para provisionar a infraestrutura na AWS.
São mais de 60 recursos/serviços provisionados na AWS.
Dentre eles tem: Um Cluster ECS, VPC, ALB, VPC Endpoint para S3/ECR, EC2, CloudWatch, Bucket s3, KMS, DynamoDB, AutoscalingGroup etc.
As maquinas estão na subnet privada utilizando NAT Gateway. O acesso ao ECR e S3 é realizado pela rede interna da AWS utilizando VPC Endpoint.

Depois que a infraestrutura é criada, é realizado o build e deploy da aplicação e atualizado a task definition.

Este projeto foi criado especificamente para ser executado pelo AWS Developer Tools (https://github.com/alysonfranklin/AwsDeveloperTools.git)

#### Passo a passo para execução
```
  $ git clone https://github.com/alysonfranklin/AwsDeveloperTools.git
  $ cd AwsDeveloperTools && terraform init && terraform plan
  $ terraform apply --auto-approve
  $ cd ..
  $ git clone ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/repo-elo7-devops_engineer
  $ cd repo-elo7-devops_engineer
  $ git clone https://github.com/alysonfranklin/elo7-devops_engineer
  $ cp -r elo7-devops_engineer/* .
  $ rm -rf elo7-devops_engineer && git add .
  $ git commit -m "terraform apply" && git push origin master
```
Acesse o serviço CodePipeline no console da AWS e você verá seu Pipeline sendo executado automaticamente após o commit/push.
![N|Solid](https://i.imgur.com/DhzDi5j.png)

Clicando em **details** na etapa **"Terraform_Plan"** você consegue visualizar o plano que o terraform criou para sua infraestrutura.
![N|Solid](https://i.imgur.com/w3CuNtK.png)

Para o Terraform aplicar as alterações é necessário clicar em **review** na etapa **Manual_Approval** e **Approve** conforme mostra imagem abaixo:
![N|Solid](https://i.imgur.com/c8n4D4K.png)

O terraform irá aplicar as alterações e você poderá ver a infraestrutura sendo criada/alterada clicando em **details** na etapa **Terraform_Apply**. 
No final será exibido o DNS do LoadBalancer que você irá copiar e colar no navegador web para acessar a aplicação.
###### Done!! =)
