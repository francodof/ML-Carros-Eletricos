#####################################################
#       Projeto 1 - Data Science Academy            #
#                                                   #
#        Machine Learning em Logística              #
#       Prevendo o Consumo de Energia de            #
#               Carros Elétricos                    #
#                                                   #
#####################################################

# Fonte dos dados:
# Hadasik, Bartłomiej; Kubiczek, Jakub (2021), 
# “Dataset of electric passenger cars with their specifications”, Mendeley Data, V2, doi: 10.17632/tb9yrptydn.2
# Disponível em: https://data.mendeley.com/datasets/tb9yrptydn/2
# Acessado em Set/2022

# Versão da Linguagem R utilizada: 
# R version 4.2.0 (2022-04-22 ucrt) -- "Vigorous Calisthenics"
# Copyright (C) 2022 The R Foundation for Statistical Computing
# Platform: x86_64-w64-mingw32/x64 (64-bit)

rm(list=ls())
dev.off()

# Configurando o diretório de trabalho
setwd("D:/Cursos/DSA/Formacao-Cientista-de-Dados/Big-Data-Analytics-R-Azure-ML/20-Projetos-com-Feedback/P01-Carros-Eletricos/Carros-Eletricos-git")
getwd()


# Carrega os pacotes
library("pacman")
p_load(readxl,dplyr, ggplot2, data.table, Amelia, GGally, caret, psych, car, lmtest)
#library(corrgram)
#library(corrplot)

search()

##### Carga e Visualização dos Dados #####

# Carrega o dataset
dados <- read_excel("./datasets/FEV-data-Excel.xlsx")

# Visualiza os dados
View(dados)

# Dimensões
dim(dados)

# Variáveis e tipos de dados
str(dados)


##### Alterando os nomes das colunas #####

names(dados)
dados <- plyr::rename(dados, c("Car full name" = "Carro",
                               "Make" = "Marca",
                               "Model" = "Modelo",
                               "Minimal price (gross) [PLN]" = "PrecoMin",
                               "Engine power [KM]" = "PotenciaMotor",
                               "Maximum torque [Nm]" = "TorqueMax",
                               "Type of brakes" = "Freios",
                               "Drive type" = "Tracao",
                               "Battery capacity [kWh]" = "CapacidadeBateria",
                               "Range (WLTP) [km]" = "AlcanceWLTP",
                               "Wheelbase [cm]" = "EntreEixos",
                               "Length [cm]" = "Comprimeto",
                               "Width [cm]" = "Largura",
                               "Height [cm]" = "Altura",
                               "Minimal empty weight [kg]" = "PesoMinimo",
                               "Permissable gross weight [kg]" = "PesoBrutoPermitido",
                               "Maximum load capacity [kg]" = "CapacidadeMaxCargaPeso",
                               "Number of seats" = "Assentos",
                               "Number of doors" = "Portas",
                               "Tire size [in]" = "TamanhoPneu",
                               "Maximum speed [kph]" = "VelocidadeMaxima",
                               "Boot capacity (VDA) [l]" = "PortaMalas",
                               "Acceleration 0-100 kph [s]" = "Aceleracao",
                               "Maximum DC charging power [kW]" = "PotenciaMaximaCargaDC",
                               "mean - Energy consumption [kWh/100 km]" = "ConsumoMedioEnergia"))


##### Análise Exploratória #####

# Verificando presença de valores ausentes
sum(!complete.cases(dados))
colSums(is.na(dados))

# Quais linhas contém valores ausentes
dados_com_na <- dados[!complete.cases(dados),]
View(dados_com_na)

# Confirmando que todas algumas colunas completas referentes ao Tesla possuem valores NA
# A motivação para buscar por valores reais, ao invés de inputar pela média das colunas
tesla <- dados_com_na %>% filter( grepl('Tesla', Marca))
rm(tesla)

# Somente os atributos cujas linhas contenham valores NA  
# Dataframe temporário, montado apenas para buscar pelos valores em documentações online
temp1 <- data.frame(select(dados_com_na, 
                            Marca, 
                            Modelo, 
                            PesoBrutoPermitido, 
                            CapacidadeMaxCargaPeso,
                            PortaMalas,
                            Aceleracao,
                            ConsumoMedioEnergia))

rm(temp1)

# Os valores faltantes foram buscados conforme explicado no Readme.md (ver seção "Observações")

# Uma vez que optou-se por não utilizar a linha referente ao veículo Mercedes-Benz EQV (long),
# ela será retirada do conjunto de dados.

dados <- dados[!grepl("Mercedes-Benz EQV", dados$Carro),]
dim(dados)


################################################################################################

# Substituição dos valores NA's

# Criando vetores com os dados faltantes. Obedecendo a ordem em que são registrados
# no dataset 'dados_com_na'

# Valores a substituir na coluna 'PesoBrutoPermitido'
vec1 <- c(2030, 2694, 2232, 2232, 2694, 2720, 3079, 3120)

# Valores a substituir na coluna 'CapacidadeMaxCargaPeso'
vec2 <- c(482, 389, 388, 388, 479, 479, 525, 623)

# Valores a substituir na coluna 'Aceleracao'
vec3 <- c(8.5, 14)

# Valores a substituir na coluna 'ConsumoMedioEnergia'
vec4 <- c(17.3, 18.4, 14.6, 15.4, 16.3, 17.8, 18.3, 20.4, 22.1)


# ***** //// *****

# Cria uma cópia do dataframe dados usando a função copy() do data.table
dados_clean <- copy(dados)

# Substitui os NA's nas respectivas colunas pelos valores dos vetores criados acima
dados_clean$PesoBrutoPermitido[is.na(dados_clean$PesoBrutoPermitido)] <- vec1
dados_clean$CapacidadeMaxCargaPeso[is.na(dados_clean$CapacidadeMaxCargaPeso)] <- vec2
dados_clean$Aceleracao[is.na(dados_clean$Aceleracao)] <- vec3
dados_clean$ConsumoMedioEnergia[is.na(dados_clean$ConsumoMedioEnergia)] <- vec4

# Verifica se todos NA's foram substituídos
sum(!complete.cases(dados_clean))

# Visualização gráfica de NA's  Amelia::missmap
missmap(dados_clean, legend = TRUE, col = c("yellow", "dodgerblue"))

# Visualiza o dataframe sem valores ausentes
View(dados_clean)

# Dimensões e tipos
dim(dados_clean)
str(dados_clean)

# Removendo as variáveis auxiliares
rm(vec1, vec2, vec3, vec4, dados_com_na)


################################################################################################

# Transforma as variáveis abaixo em categóricas
var_names <- c('Freios', 'Tracao')

dados_clean[, var_names] <- lapply(dados_clean[, var_names], factor)
str(dados_clean)

# Converte as variáveis acima para valores numéricos
dados_clean$Freios <- as.numeric(dados_clean$Freios)
dados_clean$Tracao <- as.numeric(dados_clean$Tracao)

# Apaga variável auxiliar
rm(var_names)


################################################################################################


## Análise Univariada e Multivariada - Entendendo os dados ##
names(dados_clean)

summary(dados_clean)


# Boxplots

par(mfrow = c(4,4))

boxplot(dados_clean$PrecoMin, main = "Preço Mínimo")
boxplot(dados_clean$PotenciaMotor, main = "Potência do Motor")
boxplot(dados_clean$TorqueMax, main = "Torque Máximo")
boxplot(dados_clean$CapacidadeBateria, main = "Capacidade Bateria")
boxplot(dados_clean$AlcanceWLTP, main = "Alcance (km)")
boxplot(dados_clean$VelocidadeMaxima, main = "Velocidade Máxima")
boxplot(dados_clean$PotenciaMaximaCargaDC, main = "Potência Máx DC")
boxplot(dados_clean$ConsumoMedioEnergia, main = "Consumo médio (kWh") 
boxplot(dados_clean$EntreEixos, main = "Entre Eixos")
boxplot(dados_clean$Comprimeto, main = "Comprimento")
boxplot(dados_clean$Largura, main = "Largura")
boxplot(dados_clean$Altura, main = "Altura")
boxplot(dados_clean$PesoBrutoPermitido, main = "Peso Bruto")
boxplot(dados_clean$PortaMalas, main = "Porta Malas")

# dev.off()
par(mfrow = c(1,1))
names(dados_clean)

# Verificados outliers nas seguintes variáveis:
# $PrecoMin, $PotenciaMotor, $PotenciaMaximaCargaDC, $EntreEixos, $Comprimento, $Largura, $Altura

# Analisando a variável $PrecoMin
summary(dados_clean$PrecoMin)

ggplot(data = dados_clean, aes(x = PrecoMin)) +
    geom_histogram(colour = 4, fill = 'white', bins = 15)

ggplot(data = dados_clean, aes(x = PrecoMin, y = ConsumoMedioEnergia)) +
    geom_point() +
    geom_smooth(method = 'lm')

dados_clean[order(dados_clean$PrecoMin, decreasing = TRUE), ][1:10, ]

cor(dados_clean$ConsumoMedioEnergia, dados_clean$PrecoMin)

# Como mostrados pelos gráficos e correlação, há dois modelos de carros Porsche que
# custam um valor mais alto que os demais. Isso, de certo modo, contribui para o
# declínio da curva no gráfico de $PrecoMin vs $ConsumoMedioEnergia. Note também que o erro
# é maior ao lado direito do gráfico, conforme se aproxima dos dois pontos. Percebe-se que esses carros
# custam mais, contudo, apresentam um menor consumo de energia do que o grupo anterior de carros de preços
# intermediários. Um estudo à parte poderia ser realizado visando entender o melhor custo-benefício, em termos
# do que a empresa pagaria a médio prazo com energia, versus o valor do automóvel.
# Ainda apesar dos dois pontos considerados outliers, decidiu-se por deixá-los no conjunto de dados.


# Analisando a variável #PotenciaMotor
summary(dados_clean$PrecoMin)

ggplot(data = dados_clean, aes(x = PotenciaMotor)) +
    geom_histogram(colour = 4, fill = 'white', bins = 15)

ggplot(data = dados_clean, aes(x = PotenciaMotor, y = ConsumoMedioEnergia)) +
    geom_point() +
    geom_smooth(method = 'lm')

ggplot(data = dados_clean, aes(x = PotenciaMotor, y = PrecoMin)) +
    geom_point() +
    geom_smooth(method = 'lm')

dados_clean[order(dados_clean$PotenciaMotor, decreasing = TRUE), ][1:10, ]

cor.test(dados_clean$ConsumoMedioEnergia, dados_clean$PotenciaMotor, method = 'pearson')


# Analisando a variável $PotenciaMaximaCargaDC
summary(dados_clean$PotenciaMaximaCargaDC)

ggplot(data = dados_clean, aes(x = PotenciaMaximaCargaDC)) +
    geom_histogram(colour = 4, fill = 'white', bins = 15)

ggplot(data = dados_clean, aes(x = PotenciaMaximaCargaDC, y = ConsumoMedioEnergia)) +
    geom_point() +
    geom_smooth(method = 'lm')

dados_clean[order(dados_clean$PotenciaMaximaCargaDC, decreasing = TRUE), ][1:10, c(1,21:25)]

cor.test(dados_clean$ConsumoMedioEnergia, dados_clean$PotenciaMaximaCargaDC, method = 'pearson')


# Os valores considerados outliers parecem condizentes.
# O problema maior está na pequena quantidade de observações disponíveis.
# Nada será feito quanto aos outliers, a princípio.

# Distribuição da variável target ($ConsumoMedioEnergia)
ggplot(data = dados_clean, aes(x = ConsumoMedioEnergia)) +
    geom_histogram(colour = 4, fill = 'white', bins = 9)


##### Correlações #####

# Gráfico de correlação para algumas variáveis
dados_clean %>% select(PrecoMin, PotenciaMotor, TorqueMax, CapacidadeBateria,
                    AlcanceWLTP, EntreEixos, Comprimeto, Largura, Altura,
                    PesoMinimo, PesoBrutoPermitido, CapacidadeMaxCargaPeso,
                    TamanhoPneu, VelocidadeMaxima, PortaMalas, Aceleracao,
                    PotenciaMaximaCargaDC, ConsumoMedioEnergia) %>%
    ggpairs()

# Criando uma variável para armazenar os atributos numéricos
numeric_var <- sapply(dados_clean, is.numeric)
numeric_data <- dados_clean[numeric_var]

View(numeric_data)

# Matriz de Correlação
correlacoes <- cor(dados_clean[, numeric_var])
correlacoes

# Gráficos de correlação
ggcorr(numeric_data, label = T)

numeric_data %>% ggpairs()


# Para concluir, verificando a relação de cada uma das variáveis numéricas (eixo x)
# com a variável target (eixo y)
featurePlot(x = numeric_data[, 1:21], y = numeric_data$ConsumoMedioEnergia, plot = "scatter")


# Os mini-gráficos gerados pelo featurePlot nos fornecem alguns insights.
# As medidas dos carros, como comprimento, largura, etc, possuem uma correlação positiva com o peso dos mesmos.
# Claro, um carro de dimensões maiores pesará um pouco mais. Obviamente que entre eles pode
# haver um modelo esportivo compacto mais pesado devido ao conjunto de baterias ou coisa do tipo.
# Também é claro que um veículo mais alto pode influenciar negativamente na aerodinâmica e, portanto,
# no consumo médio.
# Contudo, como está a se analisar veículos para uso em uma empresa, não interessa aqui os
# detalhes de aerodinâmica - não estamos analisando a performance de carros de corrida ou Ferraris.
# Considera-se, então, que as variações nas dimensões estejam implícitas nos atributos de peso e, assim,
# as informações de dimensões dos veículos serão omitidas do dataset a ser levado para a análise preditiva.


# Relações entre as variáveis de dimensões dos veículos e o Peso Mínimo.
par(mfrow = c(4,1))
plot(numeric_data$PesoMinimo, numeric_data$Comprimeto, xlab = 'Peso Mínimo', ylab = 'Comprimento')
plot(numeric_data$PesoMinimo, numeric_data$Largura, xlab = 'Peso Mínimo', ylab = 'Largura')
plot(numeric_data$PesoMinimo, numeric_data$Altura, xlab = 'Peso Mínimo', ylab = 'Altura')
plot(numeric_data$PesoMinimo, numeric_data$EntreEixos, xlab = 'Peso Mínimo', ylab = 'Entre Eixos')
par(mfrow = c(1,1))

# Dataframe final sem as variáveis de dimensões citadas acima.
cols_remove <- c("EntreEixos", "Comprimeto", "Largura", "Altura")
numeric_data_final <- numeric_data[, !(names(numeric_data) %in% cols_remove)]
names(numeric_data_final)

dim(numeric_data)
dim(numeric_data_final)

rm(cols_remove) # remove variável auxiliar
dev.off() # remove os gráficos armazenados na memória

# Remove demais variáveis e tabelas não necessárias
rm(correlacoes, dados_clean, numeric_data, numeric_var)


# (Opcional)
# Converte 'numeric_data_final' para data.frame e o salva em disco

df_numeric_data <- as.data.frame(numeric_data_final)

write.csv(df_numeric_data, file = "datasets/FEV_numeric.csv", row.names = FALSE)

# Removendo da memória
rm(dados, numeric_data_final)

################################################################################################

##### Análise Preditiva #####

# Dividindo o conjunto de dados em treino e teste
set.seed(100)
trainIndex <- createDataPartition(df_numeric_data$ConsumoMedioEnergia, p = .7, list = FALSE)

treino <- df_numeric_data[trainIndex,]
teste <- df_numeric_data[-trainIndex,]

data.frame(dim(treino), dim(teste))

# Métodos disponíveis do pacote caret
names(getModelInfo())

# Informações do modelo 'lm'
modelLookup('lm')


########## Modelos #########


# Modelo de regressão considerando todas as variáveis, ou quase todas,
# pois anteriormente havia-se convertido as variáveis categóricas $Tracao e $Freios para números.
# Decidiu-se não utilizá-las nos modelos. As mesmas alteraram os resultados de importância das variáveis.


## Modelo 1 utilizando a função train do pacote caret para todas as variáveis

modelo1_lm <- train(ConsumoMedioEnergia ~. -Tracao - Freios, data = treino, method = 'lm')
summary(modelo1_lm)

varImp(modelo1_lm, scale = FALSE)
plot(varImp(modelo1_lm))


# Função lm do pacote stats - útil para gerar os gráficos de análise dos resíduos
modelo1_lm <- lm(ConsumoMedioEnergia ~. -Tracao - Freios, data = treino)

par(mfrow=c(2,2))
plot(modelo1_lm)
mtext('Modelo1_lm', side = 3, line = -2, outer = TRUE, cex = 1.5)
par(mfrow=c(1,1))

# O comando acima permite visualizar 4 gráficos:
#
# 1- Residuals vs Fitted: Resíduos pelos valores ajustados.
# Permite avaliar um dos pressupostos, que é a linearidade. Se os resultados estiverem distribuídos
# de forma homogênea e simétrica em torno da reta, indica que o modelo está adequado.
#
# 2- Normal Q-Q: verifica se os resíduos apresentam distribuição normal.
# No eixo y estão os resíduos padronizados e no eixo x os resíduos teóricos caso a distribuição fosse, de fato, normal.
# Os pontos que aparecem numerados indicam aqueles casos que merecem atenção 
# pois são os que mais fogem das premissas.
#
# 3- Scale-location: Homocedasticidade. Se houver homocedasticidade a distribuição estará mais ou menos num padrão retangular.
# O gráfico indica se a variância é constante conforme o incremento da média. 
# Para a regressão, se observa um tendência de aumento da variância (representada pela raiz quadrada 
# dos resíduos padronizados no eixo y) em relação aos valores ajustados pelo modelo (eixo x).
#
# 4- Residuals vs Leverage: Verifica se existem outliers e pontos influentes.
# A linha vermelha deve passar próximo do valor 0 no eixo y, isto é coincidir com os a linha tracejada preta. 
# Os valores acima e abaixo indicam o desvio padrão destes dados (oscilação entre -3 a +3 são típicos 
# de uma distribuição normal). Além disso aparecem linhas pontilhadas que indicam a distância de Cook, 
# que é uma medida de quanto a regressão mudaria caso um dos dados fosse retirado da análise. 
# Distâncias menores que 0.5 são consideradas adequadas. 


# Complementando a análise gráfica acima

# Normalidade dos resíduos
# Teste de Shapiro-Wilk:
# H0: distribuição dos dados é normal       --> p > 0.05
# H1: distribuição dos dados não é normal   --> p ≤ 0.05

shapiro.test(modelo1_lm$residuals) 

# p-value = 0.8991, portanto > 0.05. Falha-se ao rejeitar e hipótese nula. 
# No nosso caso, a distribuição dos resíduos aproxima-se da normal


# Outliers nos resíduos padronizados
# verifica se há outliers que fogem ao intervalo de -3 a +3

summary(rstandard(modelo1_lm))

require(car)
# Independência dos resíduos (Durbin-Watson): Valores entre 1 e 3 em Statistic, não há correlação entre os resíduos
# A distribuição a ser testada deve ser normal
# H0: não há autocorrelação --> p > 0.05
# H1: existe autocorrelação  --> p ≤ 0.05

durbinWatsonTest(modelo1_lm)

# Homocedasticidade (Breusch-Pagan). A distribuição deve ser normal
# H0: Existe homocedasticidade      --> p > 0.05
# H1: Não existe autocorrelação     --> p ≤ 0.05
bptest(modelo1_lm)

# Ausência de Multicolinearidade: r > 0.9 (ou 0.8)
pairs.panels(df_numeric_data)
# VIF: Fator de inflação de variância. 
vif(modelo1_lm) # Multicolinearidade: VIF > 10


# Optou-se por tentar construir modelos mais simples, com menos variáveis. Apesar de o modelo completo
# apresentar um R^2 = 0.9354 e R^2 Ajust.= 0.8933, pela análise gráfica anterior e o VIF há grande suspeita de
# poder estar havendo multicolinearidade entre várias variáveis independentes. 

# Será utilizado o Random Forest para decidir sobre a seleção de variáveis mais importantes a serem 
# usadas nos próximos modelos, associada com os valores mais significativos apontados no
# sumário do modelo1_lm.


## Feature Selection com Random Forest

require(randomForest)
feat_sel <- randomForest(ConsumoMedioEnergia ~ . , 
                         data = df_numeric_data, 
                         ntree = 100, 
                         nodesize = 10,
                         importance = TRUE)

varImpPlot(feat_sel)

# Diante dessas observações, optou-se por escolher as seguintes variáveis:
# CapacidadeMaxCargaPeso, PortaMalas, PesoBrutoPermitido, PrecoMin, PesoMinimo, AlcanceWLTP
# AlcanceWLTP, CapacidadeBateria, TamanhoPneu, PortaMalas, VelocidadeMaxima, PotenciaMaximaCargaDC, CapacidadeMaxCargaPeso



## ****************************** ##

## Modelo 2 de regressão linear com variáveis mais significativas

modelo2_lm <- lm(ConsumoMedioEnergia ~ CapacidadeMaxCargaPeso + PortaMalas + PesoBrutoPermitido 
                 + PrecoMin + PesoMinimo + AlcanceWLTP, 
                 treino)
summary(modelo2_lm)

par(mfrow=c(2,2))
plot(modelo2_lm)
mtext('Modelo2_lm', side = 3, line = -2, outer = TRUE, cex = 1.5)
par(mfrow=c(1,1))

# Nota-se pelo gráfico Residuals vs Leverage uma verificação maior de outliers. Por outro lado,
# com essas variáveis nota-se uma homocedasticidade mais contante. Com esse modelo obtém-se:
# Multiple R-squared:  0.8372,	Adjusted R-squared:  0.8066 


## ****************************** ##

## Modelo 3 com Random Forest

modelo3_rf <- train(ConsumoMedioEnergia ~ CapacidadeMaxCargaPeso + PortaMalas + PesoBrutoPermitido 
                    + PrecoMin + PesoMinimo + AlcanceWLTP, 
                    method='rf', treino)
summary(modelo3_rf)
print(modelo3_rf)
# Resultando R^2 = 0.6886942 para mtry de 2 e RMSE de 2.184840



## ****************************** ##

## Modelo 4 com Boosted Generalized Additive Model 

modelo4_bgam <- train(ConsumoMedioEnergia ~ CapacidadeMaxCargaPeso + PortaMalas + PesoBrutoPermitido 
                      + PrecoMin + PesoMinimo + AlcanceWLTP, 
                      method='glmboost', treino)
summary(modelo4_bgam)
print(modelo4_bgam)
# Resultando R^2 = 0.7444095 para mstop de 150 e RMSE de 2.093524



##### Previsões #####

# Embora o modelo1_lm tenha, aparentemente, apresentado uma melhor acurácia, como explicado anteriormente,
# entende-se que algumas das variáveis explicativas apresentam forte autocorrelação.
# Assim, o modelo2_lm foi o escolhido  a representar o conjunto de dados. Com R^2 de 0.8372,
# esse modelo estatístico consegue explicar 83,72% da variabilidade do Consumo Médio de Energia.

predictedValues <- predict(modelo2_lm, teste)
predictedValues
plot(teste$ConsumoMedioEnergia, predictedValues)


# Tabela de comparação entre os valores reais e previstos do conjunto de dados 'teste'
table_predict <- cbind(predictedValues, teste$ConsumoMedioEnergia)
colnames(table_predict) <- c('Previsto', 'Real')
table_predict <- as.data.frame(table_predict)
table_predict
View(round(table_predict, 2))



################################################################################################






























