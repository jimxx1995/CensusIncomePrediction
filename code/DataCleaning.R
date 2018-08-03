
library(ggplot2)
library(reshape2)
library(tree)
library(rpart)
library(ipred)
library(randomForest)
library(e1071)
library(caret)
library(mlr)
library(ROCR)

training <- read.table("data/adult.data",
                       sep = ",")
test <- read.table("data/adult.test",
                   sep = ",")
names(training) <- c("age", "workclass", "fnlwgt", "education", 
                     "education_num", "marital_status", 
                     "occupation", "relationship", "race",
                     "sex", "capital_gain", "capital_loss", 
                     "hours_per_week", "native_country", "income")

names(test) <- c("age", "workclass", "fnlwgt", "education", 
                 "education_num", "marital_status", 
                 "occupation", "relationship", "race",
                 "sex", "capital_gain", "capital_loss", 
                 "hours_per_week", "native_country", "income")

#Remove missing values in workclass and native-country variables.
training2 <- training[training$workclass != " ?" &
                        training$native_country != " ?" &
                        training$occupation != " ?", ]
training2$workclass <- factor(training2$workclass)
training2$native_country <- factor(training2$native_country)

test2 <- test[test$workclass != " ?" &
                test$native_country != " ?" &
                test$occupation != "?", ]
test2$occupation <- factor(test2$occupation)
test2$workclass <- factor(test2$workclass)
levels(training2$workclass) <- levels(test2$workclass)

#Bin native-countries
counts <- table(training2$native_country)
summary(data.frame(counts))
others <- sort(counts)[1:10]
training_native_country <- training2$native_country
levels(training_native_country) <- c(levels(training_native_country), 
                                     "other")
training_native_country[training_native_country %in% names(others)] <-
  as.factor("other")
training2$native_country <- training_native_country
training2$native_country <- factor(training_native_country)
levels(training2$workclass) <- levels(test2$workclass)
test_native_country <- test2$native_country
levels(test_native_country) <- c(levels(test_native_country), "other")
test_native_country[test_native_country %in% names(others)] <-
  as.factor("other")
test2$native_country <- factor(test_native_country)
test2$workclass <- factor(test2$workclass)
#Remove the education_num and fnlwgt
training2$fnlwgt<-NULL
test2$fnlwgt<-NULL
training2$education_num<-NULL
test2$education_num<-NULL

test_income <- rep(0, nrow(test2))
for (i in 1:length(test2$income)) {
  if (test2$income[i] == levels(test2$income)[1]) {
    test_income[i] = "<=50K"
  } else {
    test_income[i] = ">50K"
  }
}
test2$income <- factor(test_income)

train_income <- rep(0, nrow(test2))
for (i in 1:length(training2$income)) {
  if (training2$income[i] == levels(training2$income)[1]) {
    train_income[i] = "<=50K"
  } else {
    train_income[i] = ">50K"
  }
}
training2$income <- factor(train_income)

save(training2, file = "data/training2.Rdata")
save(test2, file = "data/test2.Rdata")