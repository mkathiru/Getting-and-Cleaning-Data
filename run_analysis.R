filesPath <- "C:\Users\2239\Documents"
setwd(filesPath)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

###Unzip DataSet to the "data" directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

###Load required packages
library(dplyr)
library(tidyr)

filesPath <- "C:\\Users\\2239\\Documents\\data\\UCI HAR Dataset"
setwd(filesPath)
# Read subject files
tbldfSubjectTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
tbldfSubjectTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))

# Read activity files
tbldfActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))
tbldfActivityTest  <- tbl_df(read.table(file.path(filesPath, "test" , "Y_test.txt" )))

#Read data files.
tbldfTrain <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
tbldfTest  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))

## ----------------------------------------------------------------
## Merges the training and the test sets to create one data set
## ----------------------------------------------------------------

## Concatenate the data tables by rows
dataSubject <- rbind(tbldfSubjectTrain, tbldfSubjectTest)
dataActivity<- rbind(tbldfActivityTrain, tbldfActivityTest)
dataFeatures<- rbind(tbldfTrain, tbldfTest)

## set names to varibles
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <-read.table(file.path(filesPath, "features.txt" ))
names(dataFeatures)<- dataFeaturesNames$V2

## Merge columns to get the data frame Data for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## -----------------------------------------------------------------------------------------
## Extracts only the measurements on the mean and standard deviation for each measurement.
## ---------------------------------------------------------------------------------------

## 1.Subset Name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

## 2.Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

## 3.Check the structures of the data frame Data
str(Data)

## ----------------------------------------------------------------------
## Uses descriptive activity names to name the activities in the data set
## ----------------------------------------------------------------------

## 1.Read descriptive activity names 
activityLabels <- read.table(file.path(filesPath, "activity_labels.txt" ))

Data$activity <- factor(Data$activity);
Data$activity <- factor(Data$activity,labels=as.character(activityLabels$V2))

## ----------------------------------------------------------------------
## Appropriately labels the data set with descriptive variable names.
## ----------------------------------------------------------------------

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

## ----------------------------------------------------------------------
## Creates a second,independent tidy data set and ouput it
## ----------------------------------------------------------------------
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)