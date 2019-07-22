library(e1071)
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
library(e1071)
library(partykit)
library(ISLR)
library(adabag)
options(expressions = 5e5)

data <- read.csv("data/RansomwareData.csv")

data$X1 <- as.factor(as.integer(data$X1))

data <- data.frame(data$X1, data$X0, data$X0.1, data$X0.1, data$X0.2, 
                   data$X0.3, data$X0.4, data$X0.5, data$X0.6, data$X0.7, data$X0.8, data$X0.9, 
                   data$X0.10, data$X0.11, data$X0.12, data$X0.13, data$X0.14, data$X0.15, data$X0.16, 
                   data$X0.17, data$X0.18, data$X0.19, data$X0.20, data$X0.21, data$X0.22, data$X0.23, data$X0.24, 
                   data$X0.25, data$X0.26, data$X0.27, data$X0.28, data$X0.29, data$X0.30)

ind <- sample(2, nrow(data), replace = TRUE, prob = c(0.7, 0.3))
train <- data[ind==1,]
test <- data[ind==2,]

#randomForest
rf <- randomForest(data.X1~., train, ntree = 500)

print(rf)

p1 <- predict(rf, test)

p1confusion <- confusionMatrix(p1, test$data.X1)

print(p1confusion)
#calculating the important stuff
trueneg <- p1confusion$table["0", "0"]
truepos <- p1confusion$table["1", "1"]

falsepos <- p1confusion$table["1", "0"]                        
falseneg <- p1confusion$table["0", "1"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

resultsExport <- data.frame("MLA" = "RandomForest", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

#J48 Tree

j48res <- J48(data.X1~., train)

plot(j48res)

p2 <- predict(j48res, test)

p2confusion <- confusionMatrix(p2, test$data.X1)

print(p2confusion)

trueneg <- p1confusion$table["0", "0"]
truepos <- p1confusion$table["1", "1"]

falsepos <- p1confusion$table["1", "0"]                        
falseneg <- p1confusion$table["0", "1"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

d <- data.frame("MLA" = "J48", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

#adabag

adaboost <- boosting(data.X1~., train)

p3 <- predict(adaboost, test)

print(p3$confusion)

#calculating the important stuff
trueneg <- p3$confusion["0", "0"]
truepos <- p3$confusion["1", "1"]

falsepos <- p3$confusion["1", "0"]                        
falseneg <- p3$confusion["0", "1"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

d <- data.frame("MLA" = "AdaboostM1", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

#naive bayes
naive <- naiveBayes(data.X1~., train)

p4 <- predict(naive, test)

naiveTable <- table(p4, test$data.X1)

P4confusion <- confusionMatrix(p4, reference = test$data.X1)

print(P4confusion)

#calculating the important stuff
trueneg <- P4confusion$table["0", "0"]
truepos <- P4confusion$table["1", "1"]

falsepos <- P4confusion$table["1", "0"]                        
falseneg <- P4confusion$table["0", "1"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

print(naiveTable)

d <- data.frame("MLA" = "naive bayes", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

#ksvm
ksvmfit <- ksvm(data.X1~., train)

p5 <- predict(ksvmfit, test)

ksvmtable <- table(p5, test$data.X1)

print(ksvmtable)

p5confusion <- confusionMatrix(p5, reference = test$data.X1)

#calculating the important stuff
trueneg <- p5confusion$table["0", "0"]
truepos <- p5confusion$table["1", "1"]

falsepos <- p5confusion$table["1", "0"]                        
falseneg <- p5confusion$table["0", "1"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

d <- data.frame("MLA" = "ksvm", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

print(p5confusion)

#bagging 

bag <- bagging(data.X1~., data=train, coob=TRUE)

print(bag)

p6 <- predict(bag, test)

#calculating the important stuff
trueneg <- p6$confusion["0", "0"]
truepos <- p6$confusion["1", "1"]

falsepos <- p6$confusion["1", "0"]                        
falseneg <- p6$confusion["0", "1"]

accuracy <- (truepos + trueneg) / (truepos + trueneg + falsepos + falseneg)

precision <- truepos / (truepos + falsepos)

recall <- truepos / (truepos + falseneg)

fMeasure <- (2 * truepos) / (2 * truepos + falsepos + falseneg)

d <- data.frame("MLA" = "Bagging", "Accuracy" = accuracy, "Precision" = precision, "Recall" = recall, "fMeasure" = fMeasure)

resultsExport <- rbind(resultsExport, d)

#export CSV
write.csv(data, file = "dataExportTCP.csv")

write.csv(resultsExport, file = "MLAresultsTCP.csv")
