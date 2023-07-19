inst_pkg <- installed.packages()[,"Package"]
if(!"httr" %in% inst_pkg){
  message("installing httr package...")
  install.packages("httr")
}

if(!"foreach" %in% inst_pkg){
  message("installing httr package...")
  install.packages("foreach")
}

if(!"doParallel" %in% inst_pkg){
  message("installing httr package...")
  install.packages("doParallel")
}


download_opendiscourse <- function(){
  #' Opendiscourse data available at Harvard Dataverse:
  #' https://doi.org/10.7910/DVN/FIKIBO
  
  require(httr)
  
  url_list <- c("https://dataverse.harvard.edu/api/access/datafile/6544757",
                "https://dataverse.harvard.edu/api/access/datafile/6544761",
                "https://dataverse.harvard.edu/api/access/datafile/6544765",
                "https://dataverse.harvard.edu/api/access/datafile/6544780")
  filename_list <- c("electoral_terms.RDS",
                     "factions.RDS",
                     "politicians.RDS",
                     "speeches.RDS")
  
  if(dir.exists("./corpus")){
    message("traget directory... exists.")
  } else {
    dir.create("./corpus")
    print("traget directory... created.")
    print("downloading files...")
    for(i in c(1:4)){
      GET(url_list[[i]], 
          write_disk(paste0("./corpus/", 
                            filename_list[[i]]),
                     overwrite=TRUE),
          progress())
    }
    print("download finished...")
  }
}


import_opendiscourse <- function(){
  electoral_term <- readRDS("./corpus/electoral_terms.RDS")
  factions <- readRDS("./corpus/factions.RDS")
  politicians <- readRDS("./corpus/politicians.RDS")
  speeches <- readRDS("./corpus/speeches.RDS")
  
  speeches <- merge(speeches, electoral_term,
                    by.x = "electoral_term", 
                    by.y = "id")
  
  speeches <- merge(speeches, factions,
                    by.x = "faction_id", 
                    by.y = "id")
  
  speeches <- merge(speeches, politicians,
                    by.x = "politician_id", 
                    by.y = "id")
  
  return(speeches)
}

preprocessing_opendiscourse <- function(speeches){
  speeches$speech_content <- gsub("\\(\\{\\d*\\}\\)", "", speeches$speech_content)
  speeches$speech_content <- gsub("[[:punct:]]", "", speeches$speech_content)
  speeches$speech_content <- gsub("\\n", " ", speeches$speech_content)
  return(speeches)
}


download_rauh_dict <- function(){
  #' Replication data for Rauh 2018: 
  #' https://doi.org/10.1080/19331681.2018.1485608
  #' available at Harvard Dataverse: 
  #' https://doi.org/10.7910/DVN/BKBXWD

  require(httr)
  
  if(dir.exists("./dict")){
    message("traget directory... exists.")
  } else {
    dir.create("./dict")
    print("traget directory... created.")
    print("downloading files...")
    GET("https://dvn-cloud.s3.amazonaws.com/10.7910/DVN/BKBXWD/163279f3359-d9ca9c744581?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27Rauh_GermanSentimentDictionary_JITP.zip&response-content-type=application%2Fzip&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230712T213825Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=AKIAIEJ3NV7UYCSRJC7A%2F20230712%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=39921f987b836099b70290e8b2e4d573dd69b1ec57daee5a132e3746ec954dab", 
        write_disk("./dict/Rauh_GermanSentimentDictionary_JITP.zip",
                   overwrite=TRUE),
                   progress())
    utils::unzip("./dict/Rauh_GermanSentimentDictionary_JITP.zip",
                 exdir = "./dict/")
    print("download finished...")
  }
}



replace_negations <- function(speeches){
  for (i in 1:nrow(neg.sent.dictionary)){
    print(i)
    speeches$speech_content <- gsub(neg.sent.dictionary$pattern[i], 
                                    neg.sent.dictionary$replacement[i], 
                                    speeches$speech_content, fixed = FALSE)
  }
  return(speeches)
}


resolve_negations <- function(speeches){
  require(foreach)
  require(doParallel)
  
  
  path <- "./dict/"
  load(paste0(path, "Rauh_SentDictionaryGerman_Negation.Rdata"))
  load(paste0(path, "Rauh_SentDictionaryGerman.Rdata"))  
  
  
  replace_negations <- function(speeches){
    for (i in 1:nrow(neg.sent.dictionary)){
      print(i)
      speeches$speech_content <- gsub(neg.sent.dictionary$pattern[i], 
                                      neg.sent.dictionary$replacement[i], 
                                      speeches$speech_content, fixed = FALSE)
    }
    return(speeches)
  }
  
  #nc <- detectCores()
  nc <- 124
  message(paste0("Number of cores registered: ", nc))
  list_dfs <- split(speeches, rep(1:nc, each=round(nrow(speeches)/nc)))
  
  # Loop over negation dictionary, and replace instances in text
  
  cl = makeCluster(nc)
  registerDoParallel(cl)
  df <- foreach(i=1:nc, .combine='rbind') %dopar% 
    replace_negations(list_dfs[[i]])
  
  stopCluster(cl)
  return(df)
}

