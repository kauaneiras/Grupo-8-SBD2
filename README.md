# SBD2 – Dashboard Analítico de Dados Cinematográficos

## Descrição
Este projeto tem como objetivo desenvolver um dashboard analítico de filmes, utilizando dados do IMDb, com foco na análise exploratória e visualização de informações relevantes do domínio cinematográfico. A solução é baseada em um Data Warehouse estruturado segundo a arquitetura Medallion (Bronze, Silver e Gold), garantindo organização, qualidade e escalabilidade dos dados.
O projeto contempla processos de ETL, tratamento e padronização dos dados, bem como a geração de indicadores e visualizações que auxiliam na compreensão de métricas como avaliações, popularidade, duração, orçamento e receita dos filmes.

## Estrutura do Projeto

Neste projeto, estamos utilizando a arquitetura Medallion, organizada em três camadas, conforme apresentado abaixo:

```bash
dw-medallion/
 ├── Data Layer/
 │   ├── raw/      # Dados originais - Camada bronze
 │   ├── silver/   # Dados limpos e padronizados - Camada prata
 │   ├── gold/     # Dados modelados para BI - Camada Ouro
 │   └── README.md
 └── Transformer/  # ETLs
```
---

## Setup

Este repositório utiliza Git Large File Storage (Git LFS) para que seja possível realizar o upload do arquivo .csv.
Para garantir que todos os arquivos sejam baixados corretamente, siga os passos abaixo:

> **Atenção:**  
> - No **Windows**, é necessário realizar o [download e instalação do Git LFS](https://git-lfs.com/) antes de prosseguir.  
> - No **Linux**, instale o Git LFS utilizando o gerenciador de pacotes da sua distribuição (ex.: `sudo apt install git-lfs`).

```bash
git lfs install

git clone https://github.com/kauaneiras/Grupo-8-SBD2.git # Pode levar alguns minutos devido ao uso do Git LFS

cd Grupo-8-SBD2

git lfs pull
```

Para verificar se os arquivos foram devidamente baixados rode o seguinte comando:
```bash
git lfs ls-files
```

Saída esperada:
```bash
c8f3e0de0f * Data Layer/raw/dados_brutos.csv
``` 

## Equipe

A equipe é composta pelos seguintes membros:
<center>
<table style="margin-left: auto; margin-right: auto;">
    <tr> <td align="center">
            <a href="https://github.com/kauaneiras">
                <img style="border-radius: 50%;" src="https://github.com/kauaneiras.png" width="150px;"/>
                <h5 class="text-center">Kauan Eiras</h5>
            </a>
        </td>
         <td align="center">
            <a href="https://github.com/kalipassos">
                <img style="border-radius: 50%;" src="https://github.com/kalipassos.png" width="150px;"/>
                <h5 class="text-center">Kallyne Passos</h5>
            </a>
        </td>
         <td align="center">
            <a href="https://github.com/klmurussi">
                <img style="border-radius: 50%;" src="https://github.com/klmurussi.png" width="150px;"/>
                <h5 class="text-center">Kathlyn Lara</h5>
            </a>
        </td>
     <td align="center">
            <a href="https://github.com/Ninja-Haiyai">
                <img style="border-radius: 50%;" src="https://github.com/Ninja-Haiyai.png" width="150px;"/>
                <h5 class="text-center">Matheus Barros</h5>
            </a>
        </td>
        <td align="center">
            <a href="https://github.com/leanars">
                <img style="border-radius: 50%;" src="https://github.com/leanars.png" width="150px;"/>
                <h5 class="text-center">Leandro Almeida</h5>
            </a>
        </td>
</table>
