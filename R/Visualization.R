library(ggplot2)
library(reshape2)
library(tree)
library(rpart)
library(ipred)
library(randomForest)
library(e1071)
library(caret)
load("data/training2.Rdata")
load("data/test2.Rdata")

ggplot(data = training2[,c("age", "income")]) + 
  geom_boxplot(aes(y = age, x = income, fill = income)) + xlab("Income") +
  ylab("Age") + ggtitle("Age and Income")

ggplot(data = training2) + geom_bar(aes(x = workclass, fill= income)) +
  coord_flip() + ggtitle("Workclass and Income")

ggplot(data = training2) + geom_bar(aes(x = occupation, fill= income)) +
  coord_flip() + ggtitle("Occupation and Income")

ggplot(data = training2) + geom_bar(aes(x = education, fill= income)) +
  coord_flip() + ggtitle("Education and Income")

ggplot(data = training2) + geom_density(aes(x = age, fill = income), 
                                        alpha = 0.5)

ggplot(data = training2) + geom_bar(aes(x = sex, fill = income)) +
  ggtitle("Gender and Income")

ggplot(data = training2) + geom_bar(aes(x = race, fill = income)) +
  coord_flip() + ggtitle("Race and Income")
training_numerical_melt <- melt(training2[, c("age", "fnlwgt", "capital_gain", 
                                              "capital_loss", "hours_per_week",
                                              "education_num", "income")], id = "income")
ggplot(data = training_numerical_melt) + geom_boxplot(aes(x = variable, y = value))

histogram(training2$capital_gain)

histogram(training2$capital_loss)

ggplot(data = training_numerical_melt) + geom_boxplot(aes(x = variable, y = value,
                                                          fill = income))


