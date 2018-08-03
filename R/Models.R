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

## 1.Classification Tree 

#set cp =0.001 and see the change on xerror corresponding to the cp (see plotcp)
ct<- rpart(income ~., data = training2, parms = list(split = "gini"))
plot(ct)
text(ct, pretty = 0)
tree_summary <- summary(ct)

# 7 most important varibale
tree_summary$variable.importance[1:7]

#Tuning the minsplit and maxdepth
 {r,eval=FALSE}
#set the cp =0.0001
ct_tune_first <- tune.rpart(income ~., data = training2, 
                            parms =list(split="gini"),
                            minsplit=c(25,50,75,100,250,500,1000),
                            maxdepth = c(2,4,6,8,10,12,14),cp=0.0001)


#Tune the CP with cross-validation by set xval=10
#set cp =0.001 to see the changes on xerror corresponding to the cp (see plotcp)
ct_tuning_cp<- rpart(income ~., data = training2,
                     parms = list(split = "gini"),
                     minsplit =50,maxdepth = 10,
                     cp = 0.0001,xval = 10)
printcp(ct_tuning_cp)
plotcp(ct_tuning_cp)
#Choosing a CP that minimizes the cross-validated error to avoid overfitting the data
cp_value<- ct_tuning_cp$cptable[which.min(ct_tuning_cp$cptable[,"xerror"]),"CP"]

#Pruncing tree
prune_tree <- prune(ct_tuning_cp, cp = cp_value)
plot(prune_tree)
text(prune_tree, pretty = 0)
summary(prune_tree)
prune_tree_summary<-summary(prune_tree)

#Seven most important variables
prune_tree_summary$variable.importance[1:7]

#Accuracy
prune_tree_predict <- predict(prune_tree, type = "class")
prune_tree_accuracy <- sum(prune_tree_predict == training2$income) / 
  nrow(training2)
prune_tree_accuracy

#ROC and AUC
prune_tree_prob <- predict(prune_tree, type = "prob")
prune_perf <- prediction(prune_tree_prob[,2], training2$income)
tree_perf <- ROCR::performance(prune_perf, measure = "tpr", x.measure = "fpr")
#ROC
plot(tree_perf)
#AUC
auc_perf <- ROCR::performance(prune_perf, "auc")
auc_perf@y.values
 

# 2.Bagged Tree

 
bagged_tree <- randomForest(income ~.,
                            data = training2, 
                            mtry = ncol(training2) - 1, importance = TRUE)
 



#Tuning the depth of tree
 {r,eval=FALSE}
err<-c(1:9)
for (i in c(10,25,50,75,100,200,300,400,500)){
  for(j in 1:9){
    err[j]<-randomForest(income ~.,data = training2,
                         nodesize= i,
                         mtry = ncol(training2)-1,ntree=300)$err.rate[300]
  }
}

nodes_size<-c(10,25,50,75,100,200,300,400,500)
nodesize_plot<-cbind(nodes_size,err)
nodesize_plot<-as.data.frame(nodesize_plot)

#Seven most important variables
 
bag_new<-randomForest(income ~.,data = training2,
                      mtry = ncol(training2)-1,
                      ntree=300,nodesize=75,
                      importance = TRUE)

sort(bag_new$importance[,"MeanDecreaseGini"], 
     decreasing = TRUE)[1:7]

#Accuracy
bag_new_predict <- predict(bag_new, type = "class")
bag_new_accuracy <- sum(bag_new_predict == training2$income) / 
  nrow(training2)
bag_new_accuracy
 

#ROC and AUC
bag_new_prob <- predict(bag_new, type = "prob")
bag_new_perf <- prediction(bag_new_prob[,2], training2$income)
bag_perf <- ROCR::performance(bag_new_perf, measure = "tpr", x.measure = "fpr")
#ROC
plot(bag_perf)
#AUC
bag_auc_perf <- ROCR::performance(bag_new_perf, "auc")
bag_auc_perf@y.values
 


#3.Random Forest

rf <- randomForest(income ~.,data = training2, importance = TRUE)

#Tuning the depth of tree and the mtry(using the random searching in MLRpackage)
trainTask <- makeClassifTask(data = training2,target = "income")
getParamSet("classif.randomForest")
rf <- makeLearner("classif.randomForest", predict.type = "response", par.vals = list(ntree = 300))
rf_param <- makeParamSet(
  makeIntegerParam("mtry", lower = 3, upper = 15),
  makeDiscreteParam("nodesize",c(10,25,50,75,100,200,300,400,500))
)
set_cv <- makeResampleDesc("CV",iters = 3L)
rancontrol <- makeTuneControlRandom(maxit = 50L)
rf_tune <- tuneParams(learner = rf, resampling = set_cv, task = trainTask, par.set = rf_param, control = rancontrol, measures = acc)
rf_tune$y
rf_tune$x

 
#New Model with tuned parameter
rf_new <- randomForest(income ~.,data = training2,mtry=4,nodesize=400,ntree=300, importance = TRUE)
 

#Seven most important variables
sort(rf_new$importance[,"MeanDecreaseGini"], 
     decreasing = TRUE)[1:7]
 
#Accuracy
rf_new_predict <- predict(rf_new, type = "class")
rf_new_accuracy <- sum(rf_new_predict == training2$income) / 
  nrow(training2)
rf_new_accuracy
 
#ROC and AUC
rf_new_prob <- predict(rf_new, type = "prob")
rf_new_perf <- prediction(rf_new_prob[,2], training2$income)
rf_perf <- ROCR::performance(rf_new_perf, measure = "tpr", x.measure = "fpr")
#ROC
plot(rf_perf)
#AUC
rf_auc_perf <- ROCR::performance(rf_new_perf, "auc")
rf_auc_perf@y.values
 



#4.Model Selection

#Classification tree
test_predict_prob <- predict(prune_tree, test2)

test_predict <- predict(prune_tree, test2, type = "class")
tree_confusion_Matrix<-confusionMatrix(test_predict,test2$income)
tree_confusion_Matrix

tree_tpr <- tree_confusion_Matrix$byClass[3]
tree_tpr
tree_tnr <- tree_confusion_Matrix$byClass[4]
tree_tnr
tree_perf <- prediction(test_predict_prob[,2], test2$income)
test_perf <- ROCR::performance(tree_perf, measure = "tpr", x.measure = "fpr")
plot(test_perf, main = "Test Tree ROC")
test_auc <- ROCR::performance(tree_perf, "auc")
test_auc@y.values

#Bagged tree
 
bag_predict_class<- predict(bag_new, test2, type = "class")
confusionMatrix(bag_predict_class,test2$income)

bag_predict_prob <- predict(bag_new, test2, type = "prob")
bag_predict <- prediction(bag_predict_prob[,2], test2$income)
bag_perf <- ROCR::performance(bag_predict, measure = "tpr", x.measure = "fpr")
plot(bag_perf, main = "Test Bagged Tree ROC")
bag_auc <- ROCR::performance(bag_predict, "auc")
bag_auc@y.values
 

#Random Forest
rf_predict_class<- predict(rf_new, test2, type = "class")
rf_confusion_Matrix<-confusionMatrix(rf_predict_class,test2$income)
rf_confusion_Matrix

rf_tpr <- rf_confusion_Matrix$byClass[3]
tpr
rf_tnr <- rf_confusion_Matrix$byClass[4]
tnr

rf_predict_prob <- predict(rf_new, test2, type = "prob")
rt_predict <- ROCR::prediction(rf_predict_prob[,2], test2$income)
rt_perf <- ROCR::performance(rt_predict, measure = "tpr", x.measure = "fpr")
plot(rt_perf, main = "Test Random Forest ROC")
rf_auc <- ROCR::performance(rt_predict, "auc")
rf_auc@y.values

 
