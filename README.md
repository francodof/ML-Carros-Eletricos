![Capa](img\capa.png)

# Projeto Final do Curso Big Data Analytics com R e Microsoft Azure Machine Learning Versão 3.0 - Data Science Academy

O presente repositório é referente ao projeto de fim de curso do módulo Big Data Analytics com R e Microsoft Azure Machine Learning, incluso na Formação Cientista de Dados, oferecido pela Data Science Academy. Para maiores informações:

https://www.datascienceacademy.com.br/bundle/formacao-cientista-de-dados

https://www.datascienceacademy.com.br/course/analise-de-dados-com-r

Neste projeto final foi solicitado ao aluno desenvolvê-lo sozinho e, ao final, apresentá-lo à equipe do curso, a qual deve retornar com um feedback para possíveis melhorias.

----

## Sumário

- [Apresentação](#apresentação)
- [Proposta](#proposta)
- [Fonte de Dados](#fonte_dados)
- [Dicionário de Dados](#dicionario_dados)
- Observações
    - [Valores NA do Dataset](#valores_na)
- [Conclusão](#conclusao)

&nbsp;

----

<a id="apresentação"></a>
## Apresentação

Este conjunto de dados lista todos os carros de passeio totalmente elétricos com seus atributos (propriedades). A coleção não contém dados sobre carros híbridos e carros elétricos dos chamados “extensores de alcance”. Os carros de hidrogênio também não foram incluídos no conjunto de dados devido ao número insuficiente de modelos produzidos em massa e à especificidade diferente (em comparação com EV) do veículo. 

O conjunto de dados inclui carros que, a partir de 2 de dezembro de 2020, poderiam ser adquiridos na Polônia como novos em um revendedor autorizado e aqueles disponíveis em pré-venda pública e geral, mas apenas se uma lista de preços publicamente disponível com versões de equipamentos e parâmetros técnicos completos estivesse disponível. O conjunto de dados de carros elétricos inclui todos os carros totalmente elétricos no mercado primário que foram obtidos de materiais oficiais (especificações técnicas e catálogos) fornecidos por fabricantes de automóveis com licença para vender carros na Polônia. Esses materiais foram baixados de seus sites oficiais. 

&nbsp;

----
<a id="proposta"></a>
## Proposta

Uma empresa da área de transporte e logística deseja migrar sua frota para carros elétricos com o objetivo de reduzir os custos.

Antes de tomar a decisão, a empresa gostaria de prever o consumo de energia de carros elétricos com base em diversos fatores de utilização e características dos veículos.

Diante das informações contidas no dataset, a proposta é a construção de um modelo de Machine Learning capaz de prever o consumo de energia de veículos elétricos.

&nbsp;

----
<a id="fonte_dados"></a>
## Fonte de Dados

A base de dados é composta por 53 carros elétricos (cada variante de um modelo – que difere em termos de capacidade da bateria, potência do motor, etc. – é tratada separadamente) e 25 variáveis.

Hadasik, Bartłomiej; Kubiczek, Jakub (2021), “Dataset of electric passenger cars with their specifications”, Mendeley Data, V2, doi: 10.17632/tb9yrptydn.2

Disponível em: https://data.mendeley.com/datasets/tb9yrptydn/2

Acessado em Set/2022

&nbsp;

----
<a id="dicionario_dados"></a>
## Dicionário de Dados

O dataset contém as seguintes variáveis:

+ **Car full name:** nome do modelo do automóvel;
+ **Make:** marca;
+ **Model:** modelo;
+ **Minimal price (gross) [PLN]:** preço mínimo bruto em unidade monetária da Polônia;
+ **Engine power [KM]:** potência do motor em KM (até o momento não identifiquei que unidade é essa);
+ **Maximum torque [Nm]:** torque máximo em Newton-metro;
+ **Type of brakes:** tipo de freio;
+ **Drive type:** tração. Por exemplo, 2WD equivale a two-wheel drive, portanto, tração nas duas rodas.
+ **Battery capacity [kWh]:** capacidade de carga da bateria em quilowatt-hora;
+ **Range(WLTP) [km]:** alcance, em quilômetros, do veículo sob as especificações WLTP (Worldwide Harmonised Light Vehicle Test Procedure);
+ **Wheelbase [cm]:** distância horizontal entre os centros das rodas dianteiras e traseiras, em centímetros;
+ **Length [cm]:** comprimento do veículo;
+ **Width [cm]:** largura do veículo;
+ **Height [cm]:** altura do veículo;
+ **Minimal empty weight [kg]:** peso mínimo do veículo vazio;
+ **Permissable gross weight [kg]:** peso bruto permitido. O peso máximo, incluindo a carga, pessoas, malas;
+ **Maximum load capacity [kg]:** capacidade máxima de carga em kg;
+ **Number of seats:** quantidade de assetos;
+ **Number of doors:** número de portas;
+ **Tire size [in]:** tamanho do pneu em polegadas;
+ **Maximum speed [kph]:** velocidade máxima em quilômetros por hora;
+ **Boot capacity (VDA) [l]:** volume do porta-malas em litros, segundo especificações do sistema VDA (Verband der Automobilindustrie);
+ **Acceleration 0-100 kph [s]:** aceleração de 0 a 100 km/h em segundos;
+ **Maximum DC charging power [kW]:** potência máxima de carregamento DC;
+ **mean - Energy consumption [kWh/100 km]:** consumo médio de energia por 100 km.

&nbsp;

----
## Observações
<a id="valores_na"></a>
### Valores NA do Dataset

A figura abaixo mostra a filtragem onde todos os valores NA ocorrem no dataset.

![rows_na](img\rows_na.png)

Das 53 linhas do conjunto de dados, 11 delas apresentam valores ausentes. Também todos os modelos Tesla possuem valores NA em 3 dos 25 atributos, inclusive no consumo médio de energia, que é a variável target para este estudo . De antemão, sem ter o conhecimento de quais variáveis podem ser significantes para prever o consumo de energia, evitou-se a exclusão delas na análise. E pelo fato de a marca Tesla ter uma certa importância quando falamos de carros elétricos, não seria viável excluir as linhas relacionadas do dataset, até mesmo pela quantidade total de observações, que são poucas, apenas 53.

Assim, foi feita uma busca pela documentação dos referidos modelos de automóveis, a fim de preencher os dados faltantes. Note que, ainda assim, como os dados vieram de outras fontes, os valores podem não corresponder exatamente aos respectivos modelos contidos no dataset, contudo, é considerada uma forma bem razoável para representá-los.

Com exceção do modelo EQV (long) da Mercedes-Benz (observação 10 na tabela), que foi excluída da análise, os demais valores foram obtidos conforme mostrado abaixo. Tem-se o nome do modelo, a url onde os dados foram obtidos e as variáveis com os respectivos valores.

Para encontrar o consumo médio utilizamos o EVDB (Electric Vehicle Database). Segundo o site pesquisado (https://www.wilsons.co.uk/blog/how-far-do-electric-cars-really-go), o EVDB fornece uma visão geral completa de todos os veículos elétricos no Reino Unido e estima os intervalos em uma situação do mundo real.

&nbsp;

----
```
Tesla Model 3 Standard Range Plus
https://ev-database.org/car/1485/Tesla-Model-3-Standard-Range-Plus
Gross Vehicle Weight (GVWR): 2014 kg
Max. Payload: 389 kg
Vehicle Consumption: 146 Wh/km

Tesla Model 3 Long Range
https://ev-database.org/car/1321/Tesla-Model-3-Long-Range-Dual-Motor
Gross Vehicle Weight (GVWR): 2232 kg
Max. Payload: 388 kg
Vehicle Consumption: 154 Wh/km

Tesla Model 3 Performance
https://ev-database.org/car/1620/Tesla-Model-3-Performance
Gross Vehicle Weight (GVWR): 2232 kg
Max. Payload: 388 kg
Vehicle Consumption: 163 Wh/km

Model S Long Range Plus
https://ev-database.org/car/1323/Tesla-Model-S-Long-Range-Plus
https://www.evspecifications.com/en/model/37c6108
Gross Vehicle Weight (GVWR): 2694 kg
Max. Payload: 479 kg
Vehicle Consumption: 178 Wh/km

Model S Performance
https://ev-database.org/car/1324/Tesla-Model-S-Performance
https://www.evspecifications.com/en/model/3f07109
Gross Vehicle Weight (GVWR): 2720 kg
Max. Payload: 479 kg
Vehicle Consumption: 183 Wh/km

Model X Long Range Plus
https://ev-database.org/car/1325/Tesla-Model-X-Long-Range-Plus
Vehicle Consumption: 204 Wh/km
Gross Vehicle Weight (GVWR): 3079 kg
Max. Payload: 525 kg

Model X Performance
https://ev-database.org/car/1208/Tesla-Model-X-Performance
Gross Vehicle Weight (GVWR): 3120 kg
Max. Payload: 623 kg
Vehicle Consumption: 221 Wh/km

Peugeot e-2008
https://ev-database.org/car/1206/Peugeot-e-2008-SUV
Acceleration 0 - 100 km/h: 8.5 sec
Gross Vehicle Weight (GVWR): 2030 kg
Max. Payload: 482 kg
Vehicle Consumption: 184 Wh/km

Citroën ë-C4
https://ev-database.org/car/1286/Citroen-e-C4
Vehicle Consumption: 173 Wh/km

Mercedes-Benz EQV (long)
Excluído do dataset

Nissan e-NV200 evalia
https://ev-database.org/car/1117/Nissan-e-NV200-Evalia
Acceleration 0 - 100 km/h: 14.0 sec

```


Para encontrar o consumo médio utilizamos o WLTP (Procedimento de Teste de Veículos Leves Harmonizado Mundial) mencionado nos links acima. Segundo o site pesquisado (https://www.wilsons.co.uk/blog/how-far-do-electric-cars-really-go) refere-se aos valores oficiais do fabricante. 

----
<a id="conclusao"></a>
## Conclusão

O arquivo .R ainda deve passar por algumas modificações, incluindo acerca do modelo utilizado na predição. Tão logo conclua, os resultados serão mencionados nessa seção.# ML-Carros-Eletricos
