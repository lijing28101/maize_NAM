library(doParallel)
library(plyr)
library(flock)

options(stringsAsFactors = FALSE)

SobolevMetric <- function(x, y) {
  x1 <- x**2 / (sum(x**2))
  y1 <- y**2 / (sum(y**2))
  z1 <- x1 - y1
  FT <- fft(z1)
  w <- 2*pi*(1:length(FT))/(length(FT))
  s <- sum((1+w)*abs(FT)**2)**(1/2)
  return(s)
}

FisherMetric <- function(x, y) {
  x1 <- x**2 / (sum(x**2))
  y1 <- y**2 / (sum(y**2))
  t <- x1 * y1
  return(acos(sum(sqrt(t))))
}

ExtID2TermID <- function(dat, List_Top_Genes){
  return( ddply(dat, .(GO), function(x) nrow(x[(x$Gene %in% List_Top_Genes),])))
}

Enrichment_func <- function(DF_, Onto, CutOff, geneID2GOID) {
  
  GOID2TERM <-unique(geneID2GOID[,c("GO","Term")])
  rownames(GOID2TERM) <- GOID2TERM$GO
  
  EG_ <- geneID2GOID[(geneID2GOID$Ontology == Onto), ]
  annoGene <- unique(EG_[,"Gene"])
  List_Top_Genes <- DF_[rownames(DF_) %in% annoGene,1][1:CutOff]
  
  ListOfGos <- EG_[(EG_$Gene %in% List_Top_Genes),"GO"]
  ListOfGos <- unique(ListOfGos)
  ListOfGos <- ListOfGos[which(!is.na(ListOfGos))]
  
  #number of annotated genes for each of all GO
  TermID2ExtID <- ddply(EG_, .(GO), function(x) Freq_Anno=nrow(x))
  #number of annotated genes for each of GO associated with selected genes
  qTermID2ExtID <- TermID2ExtID[(TermID2ExtID$GO %in% ListOfGos), ]
  #number of selected genes for each of all GO
  qExtID2TermID <- ExtID2TermID(EG_, List_Top_Genes)
  #number of selected genes for each of GO associated with selected genes
  qExtID2TermID <- qExtID2TermID[(qExtID2TermID[ ,1] %in% ListOfGos),2]
  
  n1 = qExtID2TermID-1
  n2 = qTermID2ExtID[ ,2]
  n3 = length(unique(annoGene)) - n2
  n4 = rep(CutOff, nrow(qTermID2ExtID))
  qTermID2ExtID <- cbind(qTermID2ExtID, n1, n2, n3, n4)
  qTermID2ExtID <- qTermID2ExtID[(qTermID2ExtID[ ,2]>=5),]
  
  args.df<-qTermID2ExtID[,c(3:6)]
  pvalues <- apply(args.df, 1, function(n)
    phyper(n[1],n[2], n[3], n[4], lower.tail=FALSE))
  
  
  GOID <- qTermID2ExtID[ ,1]
  Ontology <- rep(Onto, nrow(args.df))
  Pvalue <- format(pvalues, scientific=TRUE, digits = 3)
  fdr  <- p.adjust(pvalues, method = "fdr", n = length(pvalues))
  TERM <- GOID2TERM[GOID,"Term"]
  D_EN <- data.frame(GOID=GOID, Ontology=Ontology, Pvalue=Pvalue,
                     FDR=format(fdr, scientific=TRUE, digits = 3),Term=TERM,
                     N_overlap=qTermID2ExtID$n1+1,N4GO=qTermID2ExtID$n2)
  
  D_EN <- na.omit(D_EN)
  D_EN <- D_EN[(order(as.numeric(D_EN[ ,4]))), ]
  D_EN <- D_EN[(as.numeric(D_EN[ ,4])<.05),]
  return(D_EN)
}

Prediction_Function<-function( GeneID, Method, CutOff, geneID2GOID, ExpressionData){
  
  Tareget_EX <- as.numeric(ExpressionData[GeneID,])
  if(sum(Tareget_EX)>0){
    annoGene <- unique(geneID2GOID$Gene)
    ExpressionData_PC <- ExpressionData[annoGene,]
    if( Method == "Pearson" )       SCORE <- apply( ExpressionData_PC, 1, function(x) abs(cor(as.numeric(x), Tareget_EX)))
    if( Method == "Spearman" )      SCORE <- apply( ExpressionData_PC, 1, function(x) abs(cor(as.numeric(x), Tareget_EX, method = "spearman")))
    if( Method == "FisherMetric" )  SCORE <- apply( ExpressionData_PC, 1, function(x) FisherMetric(as.numeric(x), Tareget_EX))
    if( Method == "SobolevMetric" ) SCORE <- apply( ExpressionData_PC, 1, function(x) SobolevMetric(as.numeric(x), Tareget_EX))
    if( Method == "combine" ) {
      SCORE_Pearson  <- apply( ExpressionData_PC, 1, function(x) abs(cor(as.numeric(x), Tareget_EX)))
      SCORE_Spearman <- apply( ExpressionData_PC, 1, function(x) abs(cor(as.numeric(x), Tareget_EX, method = "spearman")))
      SCORE_Fisher   <- apply( ExpressionData_PC, 1, function(x) FisherMetric(as.numeric(x), Tareget_EX))
      SCORE_Sobolev  <- apply( ExpressionData_PC, 1, function(x) SobolevMetric(as.numeric(x), Tareget_EX))
    }
    
    if( Method == "combine" ) DFScore <- data.frame( annoGene, SCORE_Pearson, SCORE_Spearman, SCORE_Sobolev, SCORE_Fisher )
    else DFScore <- data.frame( annoGene, SCORE )
    
    DFScore <- na.omit(DFScore)
    DFScore <- DFScore[(DFScore[,1]!=GeneID),]
    
    EnrichResult_all <- data.frame()
    for(Onto in c("BP","CC","MF","KO")) {
      if( Method == "Pearson" | Method == "Spearman")  EnrichResult<-Enrichment_func( DFScore[ rev(order(DFScore[,2])), ], Onto, CutOff, geneID2GOID)
      if( Method == "SobolevMetric" | Method == "FisherMetric") EnrichResult<-Enrichment_func( DFScore[order(DFScore[,2]), ], Onto, CutOff, geneID2GOID)
      if( Method == "combine" ) {
        EnrichPearson  <- Enrichment_func( DFScore[ rev(order(DFScore$SCORE_Pearson)), ], Onto, CutOff, geneID2GOID)
        EnrichSpearman <- Enrichment_func( DFScore[ rev(order(DFScore$SCORE_Spearman)), ], Onto, CutOff, geneID2GOID)
        EnrichSobolev  <- Enrichment_func( DFScore[     order(DFScore$SCORE_Sobolev) , ], Onto, CutOff, geneID2GOID)
        EnrichFisher   <- Enrichment_func( DFScore[     order(DFScore$SCORE_Fisher) , ], Onto, CutOff, geneID2GOID)
        EnrichCombine  <- rbind( EnrichPearson, EnrichSpearman, EnrichSobolev,  EnrichFisher )
        EnrichCombine  <- ddply(EnrichCombine, .(GOID), function(x) x[which.min(x$FDR),])
        EnrichResult   <- EnrichCombine[ order(as.numeric(EnrichCombine$FDR)), ]
      }
      EnrichResult_all <- rbind(EnrichResult_all,EnrichResult)
    }
    
    
    if(nrow(EnrichResult_all)>0){
      rownames(EnrichResult_all) <- c(1:nrow(EnrichResult_all))
      EnrichResult_all$GeneID=GeneID
      return(EnrichResult_all)
    }
    else {return(data.frame(GOID=NA,Ontology=NA,Pvalue=NA,FDR=NA,Term=NA,N_overlap=NA,N4GO=NA,GeneID=GeneID))
    }
  }
  else {return(data.frame(GOID=NA,Ontology=NA,Pvalue=NA,FDR=NA,Term=NA,N_overlap=NA,N4GO=NA,GeneID=GeneID))
  }
}


cores=36
cl.type="FORK"
cl <- makeCluster(cores, type = cl.type) #not to overload your computer
registerDoParallel(cl)

output="predictGO.txt"
train <- read.table("train_tpm.tsv",sep="\t",header=T)
test <- read.table("test_tpm.tsv",sep="\t",header=T)
testGene <- test$Gene_ID_ver
GOdf <- read.delim("GOdf.tsv",sep="\t",header=T)
KOdf <- read.delim("KOdf.tsv",sep="\t",header=T,quote="")
GOKOdf <- rbind(GOdf,KOdf)
expression <- rbind(train,test)
rownames(expression) <- expression$Gene_ID_ver
expression <- expression[,-1]

pred <- foreach(i=testGene) %dopar% {
  .GlobalEnv$expression = expression
  .GlobalEnv$GOdf = GOKOdf
  result <- Prediction_Function(GeneID=i,Method="combine",CutOff=150,geneID2GOID=GOKOdf,ExpressionData=expression)
  lock <- lock(output)
  write.table(result,output,sep="\t",row.names=F,quote=F,append=T,col.names=!file.exists(output))
  unlock(lock)
}

stopCluster(cl)

