## Mike Bacas - Getting and Cleaning Data - Final Project
## 4/17/2017 7:50 PM

## This script will download the proper data provided by the instructors if the datafile
## does not already exist in the working directory. It will then load the activity and feature info.
## Next, it will load the training and test datasets and keep only variables which reflect a mean
## and/or standard deviation (i.e. numeric variables). Next, it will merge the training and test dataset.
## Lastly, it will convert the "activity" and "subject" variables into factors and create a new "tidy" 
## dataset that houses the mean of each variable for each subject and activity pair.

## There will be a codebook that contains the variables and their meanings, as well as a readme file
## that explains what this script does, as well as the tidy dataset in the data repository for this project.

library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)) {
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  

if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}



## Load activity labels + features
  activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
  activityLabels[,2] <- as.character(activityLabels[,2])
  features <- read.table("UCI HAR Dataset/features.txt")
  features[,2] <- as.character(features[,2])

## Extract only the data on mean and standard deviation
  featuresMeanSTD <- grep(".*mean.*|.*std.*", features[,2])
  featuresMeanSTD.names <- features[featuresMeanSTD,2]
  featuresMeanSTD.names = gsub('-mean', 'Mean', featuresMeanSTD.names)
  featuresMeanSTD.names = gsub('-std', 'Std', featuresMeanSTD.names)
  featuresMeanSTD.names <- gsub('[-()]', '', featuresMeanSTD.names)


## Load the datasets
  train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresMeanSTD]
  trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
  trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
  train <- cbind(trainSubjects, trainActivities, train)

  test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresMeanSTD]
  testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
  testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
  test <- cbind(testSubjects, testActivities, test)

## merge datasets and add labels
  traintestMerge <- rbind(train, test)
  colnames(traintestMerge) <- c("subject", "activity", featuresMeanSTD.names)

## turn activities & subjects into factors
  traintestMerge$activity <- factor(traintestMerge$activity, levels = activityLabels[,1], labels = activityLabels[,2])
  traintestMerge$subject <- as.factor(traintestMerge$subject)

traintestMerge.melted <- melt(traintestMerge, id = c("subject", "activity"))
traintestMerge.mean <- dcast(traintestMerge.melted, subject + activity ~ variable, mean)

write.table(traintestMerge.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
write.csv(traintestMerge.mean, file = "tidy.csv")







