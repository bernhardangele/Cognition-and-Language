rm(list=ls())

library(plyr)
library(readr)
library(tibble)

sent <- read_delim("CaL Garden Path sentences and Fillers.txt", "\t")

set.seed("27032017")

sent <- add_column(sent, trialnr = sample(1:nrow(sent)), .before = TRUE)

split_words <- function(df){
  # just takes first row
  sentence <- df[1,]
  pretarget_words <- tibble(word = strsplit(sentence$pretarget, split = " ")[[1]])
  pretarget_words <- cbind(word = pretarget_words, position = "pre_ambiguity", stringsAsFactors = FALSE)
  pretarget_words[nrow(pretarget_words),]$position = "ambiguity"
  posttarget_words <- tibble(word = strsplit(sentence$posttarget, split = " ")[[1]])
  posttarget_words <- cbind(word = posttarget_words, position = "post_disambiguation", stringsAsFactors = FALSE)
  
  words <- rbind(pretarget_words, cbind(word = sentence$target, position = "disambiguation"), posttarget_words)
  
  words <- rbind(words, cbind(word = sentence$question, position = "Question"))
  
  words$type <- sentence$`Sentence type`
  
  words$comma <- sentence$comma
  
  words$question_type <- sentence$question_type
  
  words$correctResponse <- ifelse(sentence$correct == 1, "Yes", "No")
  
  words[words$position != "Question",]$correctResponse <- "Continue" 

  words
}


all_words <- ddply(.data = sent, .variables = .(trialnr), .fun = split_words)

all_words$comma <- with(all_words, ifelse(comma == 1, "no_comma", "comma"))

all_words$keyCode <- with(all_words, ifelse(position == "Question", ifelse(correctResponse == "Yes", "ArrowLeft", "ArrowRight"), "ArrowRight"))

all_words <- add_column(all_words, .before = 3, stimulusValueType = rep("text", nrow(all_words)))

all_words <- add_column(all_words, .after = 3, stimulusType = with(all_words, paste(position, type, comma, question_type, sep = "-")))

colnames(all_words)[2] <- "stimulusValue"

all_words <- subset(all_words, select = -c(trialnr, position, type, comma, question_type))

all_words$response <- all_words$correctResponse

#write_csv(all_words, "garden_path_words.csv")

write_delim(all_words, "garden_path_words.csv", delim = ";")
