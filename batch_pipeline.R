
source("helper_functions.R")

download_opendiscourse()
speeches <- import_opendiscourse()
#saveRDS(speeches, file="merged_speeches.RDS")

#subset for microbenchmarking: 0.01 percent
speeches <- speeches[speeches$electoral_term >= 18,]


library(microbenchmark)

speeches <- preprocessing_opendiscourse(speeches)
#saveRDS(speeches, file="./corpus/preprocessed.RDS")
#speeches <- load(file="./corpus/preprocessed.RDS")

download_rauh_dict()

#path <- "./dict/JITP-Replication-Final/1_Dictionaries/"
#load(paste0(path, "Rauh_SentDictionaryGerman_Negation.Rdata"))
#load(paste0(path, "Rauh_SentDictionaryGerman.Rdata"))      


#microbenchmark(replace_negations(speeches), 
#               unit = "seconds", times = 1)
# takes 403 seconds for 0.01 per cent
# would take 46.6 days

microbenchmark(df <- resolve_negations(speeches), 
               unit = "seconds", times = 1)

#df <- resolve_negations(speeches)
saveRDS(df, file="./corpus/negation.RDS")


