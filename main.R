library(jsonlite)
library(kernlab)
library(caret)
library(earth)
library(keras)


cardata <- read.csv("data/car_data.csv")

carFrame <- data.frame(data)

sample = floor(0.70 * nrow(carFrame))

set.seed(123)

ind <- sample(2, nrow(cardata), replace = TRUE, prob = c(0.7, 0.3))
train <- cardata[ind==1,]
test <- cardata[ind==2,]

train$price = as.numeric(train$price)

train$horsepower = as.numeric(train$horsepower)

str(train)

library(randomForest)

set.seed(222)

rf <- randomForest(make~., data=train,
                  ntree=1000,
                  mtry=8,
                  important=TRUE,
                  proximity=TRUE,
                  na.action=na.exclude)

print(rf)

p1 <- predict(rf, train)

plot(rf)

#TRAIN DATASET

fit <- ksvm(aspiration~., train)

print(fit)

predictions <- predict(fit, test)

print(predictions)


