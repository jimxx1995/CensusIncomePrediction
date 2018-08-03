# Census Income Prediction Project
The purpose of this project is to build models on the Census Income Data Set. The prediction task is to determine whether a person makes over 50K a year. Using the data from the Census Income Dataset, we wanted to see which tree-based method had the highest
predicitve accuracy and which variables have the strongest predictive power in regards to whether an individual
earns over $50000 in income. We compare three methods - classification trees, bagged, trees, and random
forest.We begin with preprocessing and exploration of the data. Then, we fit the three models using the
training data. With the most accurate model, we fit the test data.
 
## Data Set
The data set is in the `data` folder. It contains `adult.data` for training and `adult.test` for testing. It describes 15 variables on a sample of individuals from the US Census database. 

## Model
The code of all the models we used for training is the Rmd file in the `R` folder. 
-Classification Tree
-Bagged Tree
-Random Forest

## File Structure
```
project/
     README.md
     data/
        adult.data
        adult.test
        test2.Rdata
        training2.Rdata
     images/
        age.png
        education.png
        occupation.png
     R/
        Stat154Project.Rmd
        Stat154_Final_Version.Rmd
     report/
        Final Report (Updated).pdf
        Stat154Report.Rmd
        Stat154Report.pdf
```
## Result

The classification tree is the strongest classifier of the three methods. We built three models with optimal tuning parameters, important features , training accuracy rate, ROC curve, and AUC. Finally, we validate the best supervised classifier on the test set.The full for this project is the  Pdf file in the `report` folder. 

## Team
Team member: Jimmy Chan, Benny Chen
