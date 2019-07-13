library(jsonlite)
library(kernlab)
library(caret)
library(earth)
library(keras)

options(stringsAsFactors = TRUE)

cardata <- read.csv("data/car_data.csv")

carFrame <- data.frame(cardata)

sample = floor(0.70 * nrow(carFrame))

carFrame$price = as.numeric(as.character(carFrame$price))

carFrame$horsepower = as.numeric(as.character(carFrame$horsepower))


set.seed(123)

ind <- sample(2, nrow(carFrame), replace = TRUE, prob = c(0.7, 0.3))
train <- carFrame[ind==1,]
test <- carFrame[ind==2,]

str(train)

library(randomForest)


rf <- randomForest(aspiration~., data=train,
                  ntree=1000,
                  mtry=8,
                  important=TRUE,
                  proximity=TRUE,
                  na.action=na.exclude)

print(rf)

p1 <- predict(rf, test)

plot(rf)

plot(p1)

#TRAIN DATASET

fit <- ksvm(aspiration~., train)


print(fit)



