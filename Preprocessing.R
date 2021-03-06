#' ---
#' title: "Pre-processing"
#' output: html_document
#' ---
#' 
## ----setup, include=FALSE-------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

#' 
#' ## R Markdown
#' 
#' This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.
#' 
#' When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:
#' 
## ----import, message=FALSE, warning=FALSE---------------------------------------------------------------
library(readxl)
flights <- read_excel("flights.xlsx")

library(tidyverse)

flights <- flights[flights$cancelled != 1,]
flights <- flights[flights$diverted != 1,]

#' 
## ----utilization-Top20-and-Bottom10---------------------------------------------------------------------
df <- data.frame(tail_num = character(),
                 sum_airtime = integer(),
                 num_flights = integer(),
                 airline = character(),
                 total_delay = integer(), # sum of arrival delay
                 n_delays = integer(),
                 stringsAsFactors = FALSE)


v <- unique(flights$tail_num)
for (i in 1:length(v)) {
  sa <- sum(flights[flights$tail_num == v[i],"air_time"], na.rm = TRUE)
  nf <- nrow(flights[flights$tail_num == v[i],])
  al <- unique(na.omit(flights[flights$tail_num == v[i], "airline"]))[1]
  td <- sum(flights[flights$tail_num == v[i], "arr_delay"], na.rm = TRUE)
  nd <- nrow(flights[flights$tail_num == v[i] & flights$arr_delay > 0,])
  df <- df %>% add_row(tail_num=v[i], sum_airtime = sa, num_flights = nf, airline = al, total_delay = td, n_delays = nd)
}

df$avg_airtime <- df[,"sum_airtime"] / df[,"num_flights"]
df$avg_delay <- df[,"total_delay"] / df[,"num_flights"]
df$pct_delay <- df[,"n_delays"] / df[,"num_flights"]
df <- df[order(-df$sum_airtime),]


#' 
## ----Utilization-by-Percentile--------------------------------------------------------------------------

n_A_25pct <- round(nrow(df[df$airline == "AA",])/4,0)
n_B_25pct <- round(nrow(df[df$airline == "BA",])/4,0)
Top25pct_AA <- df[df$airline == "AA", "tail_num"][1:n_A_25pct]
Top25pct_BA <- df[df$airline == "BA", "tail_num"][1:n_B_25pct]
df_reverse <- df[order(na.omit(df$sum_airtime)),]
Bottom25pct_AA <- na.omit(df_reverse[df_reverse$airline=="AA", "tail_num"])[1:n_A_25pct]
Bottom25pct_BA <- na.omit(df_reverse[df_reverse$airline=="BA", "tail_num"])[1:n_B_25pct]

df$Top25pct_AA <- ifelse(df$tail_num %in% Top25pct_AA, TRUE, FALSE)
df$Top25pct_BA <- ifelse(df$tail_num %in% Top25pct_BA, TRUE, FALSE)
df$Bottom25pct_AA <- ifelse(df$tail_num %in% Bottom25pct_AA, TRUE, FALSE)
df$Bottom25pct_BA <- ifelse(df$tail_num %in% Bottom25pct_BA, TRUE, FALSE)

matrix <- as.matrix(df)
write.csv(matrix, "data/TailNum_by_Utilization.csv")

#' 
## ----most-common-dests-origins--------------------------------------------------------------------------


Top20_AA <- df[df$airline == "AA", "tail_num"][1:20]
Top20_BA <- df[df$airline == "BA", "tail_num"][1:20]

Bottom10_AA <- na.omit(df[df[order(df$sum_airtime),]$airline == "AA", "tail_num"])[1:10]
Bottom10_BA <- na.omit(df[df[order(df$sum_airtime),]$airline == "BA", "tail_num"])[1:10]


df_dests <- data.frame(dest = character(),
                 num_flights_Top20 = integer(),
                 num_flights_all = integer(),
                 stringsAsFactors = FALSE)
df_origins <- data.frame(origin = character(),
                 num_flights_Top20 = integer(),
                 num_flights_all = integer(),
                 stringsAsFactors = FALSE)

dests <- unique(flights$dest)
for (i in 1:length(dests)) {
  nft20 <- nrow(flights[flights$tail_num %in% Top20_AA & flights$dest == dests[i],])
  nfa <- nrow(flights[flights$dest == dests[i],])
  df_dests <- df_dests %>% add_row(dest=dests[i], num_flights_Top20 = nft20, num_flights_all = nfa)
}

origins <- unique(flights$origin)
for (i in 1:length(origins)) {
  nft20 <- nrow(flights[flights$tail_num %in% Top20_AA & flights$origin == origins[i],])
  nfa <- nrow(flights[flights$origin == origins[i],])
  df_origins <- df_origins %>% add_row(origin=origins[i], num_flights_Top20 = nft20, num_flights_all = nfa)
}

df_dests <- df_dests[order(-df_dests$num_flights_Top20),]
df_origins <- df_origins[order(-df_origins$num_flights_Top20),]

matrix_dest <- as.matrix(df_dests)
matrix_origins <- as.matrix(df_origins)
write.csv(matrix_dest, "data/DestsByUtilization.csv")
write.csv(matrix_dest, "data/OriginsByUtilization.csv")

#' 
## ----most-common-dest-origin-pairs----------------------------------------------------------------------
library(readxl)
Top_Routes <- read_excel("tableau_extracted_data/Top Dest-Origin pairs (Alpha).xlsx")

flights_by_AA_Top20 <- flights[flights$tail_num %in% Top20_AA,]
df_pairs <- data.frame(dest = character(),
                       origin = character(),
                 num_flights_Top20 = integer(),
                 num_delays = integer(),
                 stringsAsFactors = FALSE)

for (i in 1:nrow(Top_Routes)) {
  o <- Top_Routes[[i,1]]
  d <- Top_Routes[[i,2]]
  flights_from_o <- flights_by_AA_Top20[flights_by_AA_Top20$origin == o,]
  flights_from_o_to_d <- flights_from_o[flights_from_o$dest == d,]
  nft20 <- nrow(flights_from_o_to_d)
  nd <- nrow(flights_from_o_to_d[flights_from_o_to_d$arr_delay >= 0,])
  df_pairs <- df_pairs %>% add_row(dest = d, origin = o, num_flights_Top20 = nft20, num_delays = nd)
}

df_pairs <- df_pairs[order(-df_pairs$num_flights_Top20),]
df_pairs$pct_delays <- df_pairs$num_delays / df_pairs$num_flights_Top20
Top4_Routes <- df_pairs[1:4,]

matrix_pairs <- as.matrix(df_pairs)
write.csv(matrix_pairs, "data/Delays_by_Origin-Dest_Pairs_Top20_AA.csv")

#' 
