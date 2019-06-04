library(jsonlite)
library(kernlab)
library(caret)
library(earth)


cardata <- read.csv("data/car_data.csv")

carFrame <- data.frame(data)

sample = floor(0.70 * nrow(carFrame))

set.seed(123)

trainindex <- sample(seq_len(nrow(carFrame)), size = sample)

train <- cardata[trainindex, ]

test <- cardata[-trainindex, ]


#TRAIN DATASET

fit <- ksvm(train)


print(fit)

predictions <- predict(fit)

print(predictions)

