# docker-androidsdk

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://opensource.org/licenses/MIT)
  
---  
  
Uma imagem docker com alguns utilitários para servir de base para processo de build de aplicações android. A ideia é que não sejam necessárias ferramentas adicionais para conseguir empacotar uma aplicação android, apenas o docker e o restante (padrão) fica por conta desta imagem.

Cada projeto deverá ter sua particularidade no processo de build, para esses casos, o projeto deve ter seu **Dockerfile** e o ponto de partida deste será essa imagem.

O ponto de partida desta imagem base é: **openjdk:8-jdk**

Esta imagem possui:

- git 
- mercurial 
- curl 
- wget 
- rsync 
- expect 
- python 
- python-dev 
- python-pip 
- build-essential 
- zip 
- unzip 
- tree 
- clang 
- imagemagick 
- awscli 
- software-properties-common 
- maven
- ant
- gradle 
- go
- nodejs

Os pontos chave dela são:

- android-sdk-tools
- sdkmanager
- buck
  
---
  
## Exemplos de uso

Na pasta *examples* deste repositório existem subpastas com nomes de builders. Execute os passos abaixo para utilizar esta imagem.

1. Copie o arquivo *docker-compose.yml* da pasta que se adequa com seu projeto para a pasta raiz do projeto;
2. Caso necessário altere o *command* para que fique de acordo com sua necessidade;
3. Execute a linha de comando ```docker-compose run android_build```;

> Caso tenha problemas de certificados SSL (por conta de sua rede), talvez ajude descomentar a linha de certificados e caso necessário ajustar os caminhos na sua máquina.