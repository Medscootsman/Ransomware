#install.packages("plyr")
#install.packages("readr")
library(plyr)
library(readr)
library(randomForest)
library(dplyr)
set.seed(123)
files <- list.files(path = "data/httpdata", pattern = "*.csv", full.names = TRUE)

data <- ldply(files, read_csv)

data=data %>% mutate_if(is.character, as.factor)

data$uri_size <- as.integer(as.character(data$uri_size))

data$bytes <- as.double(as.character(data$bytes))

data$sourceport <- as.double(as.character(data$sourceport))

data$sourceIP <- as.double(as.character(data$sourceIP))

data$destIP <- as.double(as.character(data$destIP))

data$host <- as.character(data$host)

data$uri <- as.character(data$uri)

data$body <- as.character(data$body)

train <- data[1:1800,]
test <- data[1801:2911,]


data <- na.exclude(train)
train <- select(train, -c(14))

summary(train)

levels(train$agent)

rf <- randomForest(type ~., data = train, na.action = na.exclude)

