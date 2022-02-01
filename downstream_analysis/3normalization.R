library(DESeq2)
library(EnvStats)
library(sva-devel)

#DESeq normalization for each single study
getdeseq <- function(countdf, runinfo){
  norm_count <- list()
  study <- as.character(unique(runinfo$study_accession))
  ncol=length(study)
  single_srp <- c()
  for (i in 1:ncol){
    srp <- study[i]
    srr <- as.character(runinfo$run_accession[runinfo$study_accession==srp])
    df <- countdf[,srr]
    if(length(srr)==1){
      df <- as.matrix(df)
      colnames(df) <- srr
      norm_count[[i]] <- df
      single_srp <- c(single_srp,srr)
    } else {
      df2 <- df
      df2[df2==0] <- NA
      df_geoMean <- apply(df2,1,function(x)geoMean(x,na.rm = T))
      df_factor<- estimateSizeFactorsForMatrix(df, geoMeans=df_geoMean)
      normalization <- sweep(df,2,df_factor,"/")
      norm_count[[i]] <- normalization
    }
  }
  norm_count_single <- do.call(cbind,norm_count)
  return(list(norm_count_single,single_srp))
}

runinfo <- read.table("study_srr",sep="\t",header=T)
tpm <- readRDS("JL_2021-02-16_B73_tpm_ex.rds")
tpm_only <- tpm[,-c(1:8)]
deseq1 <- getdeseq(tpm_only,runinfo)
tpm_combat <- ComBat_seq(deseq1$norm_count_single[,!(colnames(deseq1$norma_count_single) %in% deseq1$single_srp)], 
                         batch = runinfo$study_accession[!(runinfo$run_accession %in% deseq1$single_srp],
                         group = runinfo$group)

lognorm <- log(tpm_combat + 1)