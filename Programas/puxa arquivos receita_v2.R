# Pacotes requeridos - caso nao os tenha instalado antes, instale.
# estao comentados para nao serem executados sem necessidade
  # install.packages("stringr")
  # install.packages("data.table")
  # install.packages("dplyr")
  # install.packages("readxl")
  # install.packages("RCurl")

# abre pacotes requeridos OBS: sempre executar essas linhas 
library(data.table)
library(dplyr)
library(stringr)
library(data.table)
library(readxl)
library(RCurl)

#######  Dicionario de blocos ###
  # Tabela Blocos
  # Bloco Descrição
  # 0     Abertura, Identificação e Referências
  # C     Documentos Fiscais I - Mercadorias (ICMS/IPI)
  # D     Documentos Fiscais II - Serviços (ICMS)
  # E     Apuração do ICMS e do IPI
  # G*    Controle do Crédito de ICMS do Ativo Permanente - CIAP
  # H     Inventário Físico
  # 1     Outras Informações
  # 9     Controle e Encerramento do Arquivo Digital


# Abre arquivo agrupado em 1 coluna
teste<-read.table("D:/Downloads/Teste.txt", blank.lines.skip = T, stringsAsFactors = F,
                  sep = "\r", header = F, encoding = "cp1252", colClasses = "character")
setDT(teste)



# separa colunas
  # verifica tamanho maximo de colunas a serem repartidas
    splits <- max(lengths(strsplit(teste$V1, "|", fixed = T)))
  # gera colunas repartindo pelo delimitador 
    teste[, paste0("A", 0:as.numeric(splits-1)) := tstrsplit(V1, "|", fixed=T )]
    
  # testa se foi puxado corretamente e limpa arquivo
    teste[, V1:=NULL]
    teste[A0=="", .N] #aqui eu testo se a primeira coluna é toda em branco
    teste[, A0:=NULL]
    # vamos renomeiar REG para ter seguranca de programacao
    colnames(teste)[1]<-"REG"

# Baixa descricao de cfop do site da fazenda 
    # caminho do arquivo na internet
      url <- "http://www.nfe.fazenda.gov.br/PORTAL/exibirArquivo.aspx?conteudo=q45CSx9EjV8="
    
    # coloca na pasta de temporarios e da nome ao arquivo baixado
      pasta_temporaria<-file.path(tempdir(),"CFOP_table.xlsx")
      download.file(url, pasta_temporaria, mode = "wb")
      
    # carrega arquivo em excel baixado
      CFOP_table <- read_excel("C:/Users/tamara vaz/AppData/Local/Temp/RtmpK4mzS5/CFOP_table.xlsx")]

# Vincula arquivos C100 e D100 aos arquivos filhos
  #  Gera chave unica para todos arquivos C100 ou D100
    teste[, chave:=0]
    teste[substr(REG,1,1)=="D" | substr(REG,1,1)=="C", chave:=NA ]
    teste[, chave:=as.integer(chave)][REG=="D100", chave:= 1:.N, REG]

  # Replica codigo das notas para reg filhos
    aux1 <- teste$chave[1]
    for(x in seq.int(2, length(teste$chave))){if(is.na(teste$chave[x])){ teste$chave[x] <- aux1 }else{ aux1 <- teste$chave[x]} }

      
######## RELATORIO DE CFOP, REPRODUCAO DO CLICK ########
 # o guia RFB elenca os seguintes registros para apuracao no E110
      #C190,C320,C390,C490,C590, C690,C790,C850,C890,D190,D300,D390,
      #D410, D590,D690,D696
      
  # construindo relatorio puxando cada campo de cada registro elencado acima
    relatorio_cpf<- 

