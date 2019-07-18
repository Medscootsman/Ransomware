#install.packages("plyr")
#install.packages("readr")
#install.packages("dplyr")
#install.packages("iptools")
#install.packages("partykit")
library(plyr)
library(readr)
library(randomForest)
library(dplyr)
library(iptools)
library(jsonlite)
library(caret)
library(earth)
library(keras)
library(caTools)
library(RWeka)
library(kernlab)
library(partykit)

options(stringsAsFactors = TRUE)

#PREPARATION
set.seed(123)
files <- list.files(path = "data/httpdata", pattern = "*.csv", full.names = TRUE)

data <- ldply(files, read_csv)

data=data %>% mutate_if(is.character, as.factor)

data$uri_size <- as.integer(as.character(data$uri_size))

data$bytes <- as.integer(as.character(data$bytes))

data$sum <- as.integer(as.character(data$sum))

data$tcpwin <- as.integer(as.character(data$tcpwin))

data$bodySize <- as.integer(as.character(data$bodySize))

data$hostLength <- as.integer(as.character(data$hostLength))

data$sourceport <- as.integer(as.character(data$sourceport))

data$sourceIP <- iptools::ip_to_numeric(as.character(data$sourceIP))

data$destIP <- iptools::ip_to_numeric(as.character(data$destIP))

data$host <- as.numeric(data$host)

data$tcpack <- as.numeric(as.character(data$tcpack))

dataV2 <- data.frame(data$type, data$sourceIP, data$destIP, data$bytes, data$sourceport, data$method, data$bodySize, 
                     data$version, data$fileType, data$uri_size, data$agent, data$hostLength, data$onion, data$comDomain, 
                     data$sum, data$flags, data$tcpwin, data$tcpack)


ind <- sample(2, nrow(dataV2), replace = TRUE, prob = c(0.7, 0.3))
train <- dataV2[ind==1,]
test <- dataV2[ind==2,]

summary(train)

levels(train$agent)

#randomforest
rf <- randomForest(data.type ~., data = train, na.action = na.exclude, ntree = 500, mtry = 8)

print(rf)

p1 <- predict(rf, newdata = test)

rftable <- table(test$data.type, p1)

print(rftable)

p1confusion <- confusionMatrix(p1, reference = test$data.type)

print(p1confusion)

plot(rf)

#calculating the important stuff
trueneg <- p1confusion$table["Benign", "Benign"]
truepos <- p1confusion$table["Malicious", "Malicious"]

falsepos <- p1confusion$table["Malicious", "Benign"]                        
falseneg <- p1confusion$table["Benign", "Malicious"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

resultsExport <- data.frame("MLA" = "RandomForest", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

#J48
j48res <- J48(data.type~., train)

p2 <- predict(j48res, newdata = test)

print(j48res)

j48table <- table(test$data.type, p2)

print(j48table)

p2confusion <- confusionMatrix(p2, reference = test$data.type)

print(p2confusion)

plot(j48res)

#calculating the important stuff
trueneg <- p2confusion$table["Benign", "Benign"]
truepos <- p2confusion$table["Malicious", "Malicious"]

falsepos <- p2confusion$table["Malicious", "Benign"]                        
falseneg <- p2confusion$table["Benign", "Malicious"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

d <- data.frame("MLA" = "J48", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

#adaboost
#install.packages("adabag")
library(adabag)

adaboost <- boosting(data.type~., train, boos = TRUE, mfinal = 50)

p3 <- predict(adaboost, test)


#calculating the important stuff
trueneg <- p3$confusion["Benign", "Benign"]
truepos <- p3$confusion["Malicious", "Malicious"]

falsepos <- p3$confusion["Malicious", "Benign"]                        
falseneg <- p3$confusion["Benign", "Malicious"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

d <- data.frame("MLA" = "AdaboostM1", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

#naive bayes
#install.packages("e1071")
library(e1071)
naive <- naiveBayes(data.type~., train)

p4 <-predict(naive, test)

naiveTable <- table(p4, test$data.type)

trueneg <- naiveTable[1, "Benign"]

P4confusion <- confusionMatrix(p4, reference = test$data.type)

print(P4confusion)

#calculating the important stuff
trueneg <- p4confusion$table["Benign", "Benign"]
truepos <- p4confusion$table["Malicious", "Malicious"]

falsepos <- p4confusion$table["Malicious", "Benign"]                        
falseneg <- p4confusion$table["Benign", "Malicious"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

print(naiveTable)

d <- data.frame("MLA" = "naive bayes", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

#ksvm
ksvmfit <- ksvm(data.type~., train)

p5 <- predict(naive, test)

ksvmtable <- table(p5, test$data.type)

print(ksvmtable)

p5confusion <- confusionMatrix(p5, reference = test$data.type)

#calculating the important stuff
trueneg <- p5confusion$table["Benign", "Benign"]
truepos <- p5confusion$table["Malicious", "Malicious"]

falsepos <- p5confusion$table["Malicious", "Benign"]                        
falseneg <- p5confusion$table["Benign", "Malicious"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

d <- data.frame("MLA" = "ksvm", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

print(p5confusion)

#export CSV
write.csv(data, file = "dataExport.csv")

write.csv(resultsExport, file = "MLAresults.csv")


