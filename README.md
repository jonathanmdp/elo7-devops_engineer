# CI/CD com AWS e Terraform - Infraestrutura pronta para produção

[![N|Solid](https://miro.medium.com/max/1568/1*DqldXuoO53SQrT137Op4IQ.png)](https://www.linkedin.com/in/alysonfranklin/)

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://www.linkedin.com/in/alysonfranklin/)

Este código foi criado para provisionar a infraestrutura na AWS.
São mais de 60 recursos provisionados na AWS.
Dentre eles tem: Um Cluster ECS, VPC, ALB, VPC Endpoint para S3/ECS/ECS Telemetry/ECS Agent/ECR, EC2 Instance, CloudWatch, Bucket s3, KMS, DynamoDB, AutoscalingGroup etc.
As maquinas estão na subnet privada utilizando NAT Gateway. O acesso ao ECR e S3 é realizado pela rede interna da AWS utilizando VPC Endpoint.

Para instâncias do Amazon EC2 executando os agentes do ECS em uma VPC, você precisa dos três Endpoints para conectar-se totalmente por meio do **PrivateLink**. O endpoint "ecs" é da API de front-end que hospeda as APIs normais que seriam usadas pela CLI, SDK etc., bem como o que o próprio agente do ECS usa para sinalizar várias alterações de estado nas tarefas.
Os endpoints "ecs-agent" e "ecs-telemetry" representam as APIs do soquete da Web que o agente ECS requer para executar várias atividades de orquestração. Fora do PrivateLink, ele normalmente se conectaria a endpoint externos para essa finalidade.

Depois que a infraestrutura é criada, é realizado o build e deploy da aplicação e atualizado a task definition. No final do processo é exibido o DNS do LoadBalancer no CodeBuild. Acesse a aplicação no navegador utilizando o DNS do Loadbalancer

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
  $ git commit -am "terraform apply" && git push origin master
```
Acesse o serviço CodePipeline no console da AWS e você verá seu Pipeline sendo executado automaticamente após o commit/push.
![N|Solid](https://i.imgur.com/DhzDi5j.png)

Clicando em **details** na etapa **Terraform_Plan** você consegue visualizar o plano que o terraform criou para sua infraestrutura.
![N|Solid](https://i.imgur.com/w3CuNtK.png)

Para o Terraform aplicar as alterações é necessário clicar em **review** na etapa **Manual_Approval** e **Approve** conforme mostra imagem abaixo:

![N|Solid](https://i.imgur.com/c8n4D4K.png)

O terraform irá aplicar as alterações e você poderá ver a infraestrutura sendo criada/alterada clicando em **details** na etapa **Terraform_Apply**. 
No final será exibido o DNS do LoadBalancer que você irá copiar e colar no navegador web para acessar a aplicação.

##### Excluindo a infraestrutura criada pelo AWS Developer Tools

Edite o arquivo **buildspec_terraform_plan.yml** e deixe-o conforme mostrado na imagem abaixo:
![N|Solid](https://i.imgur.com/EU4PINs.png)
Após editar e salvar o arquivo, faça o commit/push e aguarde a infraestrutura ser excluída.
Para visualizar o andamento da exclusão da infraestrutura, acesse o Pipeline criado no primeiro passo.

OBS: Não esqueça de excluir os serviços AWS Developer Tools rodando **terraform destroy --auto-approve** diretamente na sua maquina local.
#### Done!! =)

### Conselho
Eu recomendo fortemente que você crie um projeto no CodeBuild apenas para deploy da aplicação e outro para provisionar a infraestrutura via Terraform. Assim fica mais organizado e também é uma boa pratica, visto que na maioria das vezes será realizado mais deploy da aplicação do que alteração na infraestrutura, o deploy será realizado em um tempo mais curto e você não correrá o risco de modificar alguma coisa errada na infraestrutura.

No meu ambiente atual eu tenho Bluegreen e Canary Release. Em breve atualizarei este código com esses recursos.

##### Sugestões, críticas e pull requests são bem vindos!
