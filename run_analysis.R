## Set filename

filename <- "UCI_HAR_dataset.zip"

## Download zip (in windows machine don't need "method=curl")
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename,mode='wb')
}  

##unzip file

if (!file.exists("UCI HAR Dataset")) {
  unzip(filename) 
}

# Load activity labels + features
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
features_filter <- grep(".*mean.*|.*std.*", features[,2])
features_filter.names <- features[features_filter,2]
features_filter.names = gsub('-mean', 'Mean', features_filter.names)
features_filter.names = gsub('-std', 'Std', features_filter.names)
features_filter.names <- gsub('[-()]', '', features_filter.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_filter]
train_y <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_Subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_Subjects, train_y, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_filter]
test_y <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_Subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_Subjects, test_y, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", features_filter.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activity_labels[,1], labels = activity_labels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)