#install.packages("plyr")
#install.packages("readr")
#install.packages("dplyr")
#install.packages("iptools")
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

dataV2 <- data.frame(data$type, data$sourceIP, data$destIP, data$bytes, data$sourceport, data$method, data$bodySize, 
                     data$version, data$fileType, data$uri_size, data$agent, data$hostLength, data$onion, data$comDomain, 
                     data$sum, data$flags, data$tcpwin)


ind <- sample(2, nrow(dataV2), replace = TRUE, prob = c(0.7, 0.3))
train <- dataV2[ind==1,]
test <- dataV2[ind==2,]

summary(train)

levels(train$agent)

#randomforest
rf <- randomForest(data.type ~., data = train, na.action = na.exclude, ntree = 800, mtry = 8)

print(rf)

p1 <- predict(rf, newdata = test)

rftable <- table(test$data.type, p1)

print(rftable)

#J48
j48res <- J48(data.type~., train)

test.pred <- predict(j48res, newdata = test)

print(j48res)

j48table <- table(test$data.type, test.pred)

print(j48table)
#naive bayes

