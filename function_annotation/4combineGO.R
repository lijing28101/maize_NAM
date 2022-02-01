library("data.table",quietly = T)
library("tools",quietly = T)
library("ontologyIndex",quietly = T)

gaf_cols = c("db", "db_object_id", "db_object_symbol", "qualifier", "term_accession", "db_reference", "evidence_code", "with", "aspect", "db_object_name", "db_object_synonym", "db_object_type", "taxon", "date", "assigned_by", "annotation_extension", "gene_product_form_id")

read_gaf = function(infile){
  if(!file.exists(infile)){
    warning("The file does not exist")
    break
  }
  #gaf_cols = fread(gaf_col_file,header=F)$V1
  con <- file(infile, "r", blocking = FALSE)
  first_lines = readLines(con,n = 100)
  close(con)
  comment_lines = max(grep("^!",first_lines))
  
  
  curr_gaf = fread(infile,skip = comment_lines,header = F,stringsAsFactors = F,colClasses = c(rep("character,17")))
  colnames(curr_gaf) = gaf_cols
  curr_gaf[is.na(curr_gaf)] = ""
  return(curr_gaf)
}

write_gaf = function(out_gaf,outfile){
  out_gaf[is.na(out_gaf)] = ""
  
  unfilled_gaf_col = gaf_cols[!gaf_cols %in% colnames(out_gaf)]
  
  for(col in unfilled_gaf_col){
    out_gaf[,c(col):=""]
  }
  out_gaf = out_gaf[,c(gaf_cols),with=F]
  setcolorder(out_gaf,gaf_cols)
  
  dir.create(dirname(outfile),recursive = T,showWarnings = F)
  
  cat("!gaf-version:2.0\n",file = outfile)
  cat("!",paste(colnames(out_gaf),collapse = "\t"),file = outfile,append = T,sep = "")
  cat("\n",file = outfile,append = T)
  
  write.table(out_gaf,outfile,quote = F,sep = "\t",append = T,row.names = F,col.names = F)
}



check_obo_data = function(obo){
  obo_data = paste(obo,".data",sep="")
  
  print(paste("Checking if ", obo_data," exists", sep=""))
  if(file.exists(obo_data)){
    print(paste(obo_data," exists so loading R object", sep=""))
    print(system.time({
      load(obo_data)
    }))
    
  }else{
    print(paste("", obo_data," does not exist. So reading ",obo," and saving the R object", sep=""))
    print(paste("Reading",obo))
    print(system.time({
      go_obo = get_ontology(obo,propagate_relationships = c("is_a","part_of"),extract_tags="everything")
    }))
    alt_conv = get_alt_id(go_obo)
    go_obo$alt_conv = alt_conv
    go_obo$ns2go = get_ns2go(go_obo)
    go_obo$aspect = get_aspect(go_obo)
    save(go_obo,file=obo_data)
  }
  
  return(go_obo)
}

go_obo = check_obo_data("go.obo")
raw_data <- c("Araport11.gaf","uniprot.gaf",'interproscan.gaf')
for(i in ){
  in_gaf=i
  out_gaf=paste0("nr_",i)
  nrgaf <- rm_gaf_red(uniq_data,go_obo)
  write_gaf(nrgaf,out_gaf)
}

obs_and_alt = c(unlist(go_obo$alt_id[go_obo$obsolete]),names(go_obo$obsolete[go_obo$obsolete]))
nr_datasets <- paste0("nr_", raw_data)

tmp_datasets = lapply(nr_datasets,function(x){
  data = read_gaf(x)
})
all_datasets = do.call(rbind,tmp_datasets)
all_datasets = gaf_check_simple(go_obo,all_datasets)

print(NROW(all_datasets))

#remove redundancy to get the minimal set
print(paste("Removing Redundancy"))
unit_perc = 1
unit_size = (NROW(all_datasets) %/% 100 / unit_perc)+1
print(unit_size)

#order the dataset by gene and aspect for index to make sense
all_datasets = all_datasets[order(db_object_id,aspect)]
out_uniq_data <- compile_nr_comp(all_datasets)
out_data = out_uniq_data[,rm_red(.SD,aspect,db_object_id,go_obo,obs_and_alt,.I,unit_size,unit_perc,"Comp"),by=list(db_object_id,aspect)]

#the columns will be reordered so make sure to reorder the columns for GAF 2.x specs
setcolorder(out_data,gaf_cols)
write_gaf(out_data,"final_combined.gaf")


