# docker-builder-android

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://opensource.org/licenses/MIT)

---  

Uma imagem docker com alguns utilitários para servir de base para processo de build de aplicações android. A ideia é que não sejam necessárias ferramentas adicionais para conseguir empacotar uma aplicação android, apenas o docker e o restante (padrão) fica por conta desta imagem.

Cada projeto deverá ter sua particularidade no processo de build, para esses casos, o projeto deve ter seu **Dockerfile** e o ponto de partida deste será essa imagem.

O ponto de partida desta imagem base é: **macielbombonato/docker-builder**

Esta imagem possui:

- android-sdk-tools
- sdkmanager

---

## Exemplos de uso

### Como um agente do Jenkins

Na pasta *examples* temos a subpasta *jenkins-agent*. Edite as variáveis de ambiente contidas no arquivo *docker-compose.yml* para atender as necessidades do seu projeto e em seguida execute a linha de comando abaixo (no mesmo diretório deste yml).

```
docker-compose up
```

O comportamento esperado é que a imagem suba e se conecte como agente do seu Jenkins conforme configuração fornecida.

---  

### Para execução direta

Na pasta *examples* deste repositório existem subpastas com nomes de builders. Execute os passos abaixo para utilizar esta imagem.

1. Copie o arquivo *docker-compose.yml* da pasta que se adequa com seu projeto para a pasta raiz do projeto;
2. Caso necessário altere o *command* para que fique de acordo com sua necessidade;
3. Execute a linha de comando ```docker-compose run android_build```;

> Caso tenha problemas de certificados SSL (por conta de sua rede), talvez ajude descomentar a linha de certificados e caso necessário ajustar os caminhos na sua máquina.

> OBS.: Após o processo de build ser executado com sucesso, execute ```docker-compose down```. Isso deve garantir que sua máquina não mantenha containers no ar sem necessidade.

---

### Customizando a imagem

Caso a imagem como está não atenda todas suas necessidade, é possível realizar customizações nela.

No diretório ```examples/gradle-sonar``` existe um exemplo onde a imagem base recebeu algumas customizações para que o processo de build já realizasse a publicação do relatório no Sonarqube no final do processo.

Neste caso, copie os dois arquivos desta pasta para o diretório raiz do seu projeto, realize os ajustes necessários neles e execute os comandos abaixo.

```
docker-compose build
docker-compose run android_build
```

---  
