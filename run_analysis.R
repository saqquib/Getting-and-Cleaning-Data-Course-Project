#download and unzip csv file
if (!(file.exists("Project"))){
  dir.create("Project")
}

URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(URL,"project.zip",mode = "wb")

unzip("project.zip", exdir = "/Project")

#Read features file into table
features_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\features.txt"
features_table <- read.table(features_file)

#Get List of column names in features table to replace in test tables
feature_names <- features_table[,2]

#Replace Column Names in X_test file
x_test_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\test\\X_test.txt"
x_test_table <- read.table(x_test_file)
colnames(x_test_table) <- make.unique(feature_names)

#Replace Column Names in X_training file
x_training_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\train\\X_train.txt"
x_training_table <- read.table(x_training_file)
colnames(x_training_table) <- make.unique(feature_names)

#load Y files
y_test_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\test\\y_test.txt"
y_test_table <- read.table(y_test_file)

y_training_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\train\\y_train.txt"
y_training_table <- read.table(y_training_file)

#load subject files
test_subject_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\test\\subject_test.txt"
test_subject_table <- read.table(test_subject_file)
training_subject_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\train\\subject_train.txt"
training_subject_table <- read.table(training_subject_file)

#Create function to add ID column to all tables
x_test_table <- mutate(x_test_table, ID = row_number())
x_training_table <- mutate(x_training_table, ID = row_number())
y_test_table <- mutate(y_test_table, ID = row_number())
y_training_table <- mutate(y_training_table, ID = row_number())
test_subject_table <- mutate(test_subject_table, ID = row_number())
training_subject_table <- mutate(training_subject_table, ID = row_number())

#Join with X and Y table (subject & test)
test_file_merge1 <-  x_test_table %>% merge(y_test_table,by.x = "ID", by.y = "ID") %>% rename(ActivityID = V1)
training_file_merge1 <- x_training_table %>%  merge(y_training_table, by.x = "ID", by.y = "ID") %>% rename(ActivityID = V1)

#Join with subject table
test_file_merge1 <- test_file_merge1 %>% merge(test_subject_table, by = "ID") %>% rename(SubjectID = V1)
training_file_merge1 <- training_file_merge1 %>% merge(test_subject_table, by = "ID") %>% rename(SubjectID = V1)

#Load Activity File and merge with other tables
activity_file <- "C:\\Users\\jjmar\\OneDrive\\Documents\\R---Data-Science-Class\\Temporary_For_version_control\\HelloWorld\\Project\\UCI HAR Dataset\\activity_labels.txt"
activity_table <- read.table(activity_file)

activity_table <- rename(activity_table, ActivityID = V1, Activity = V2)

test_file_merge1 <- merge(test_file_merge1, activity_table, by = "ActivityID")
training_file_merge1 <- merge(training_file_merge1, activity_table, by = "ActivityID")

#Combine both dataframes
test_and_training_df <- rbind(test_file_merge1, training_file_merge1)
test_and_training_df <- select(test_and_training_df, Activity, contains("Mean"), contains("std"))

#Create separate dataset for mean of columns grouped by activity
dt <- as.data.table(test_and_training_df)
dt <- dt[ , lapply(.SD, mean), by  = "Activity"]

#Write DataFrames to excel files
write.csv(test_and_training_df, file = "test_and_training_data.csv", row.names = FALSE)
write.csv(dt, "means_by_activity.csv", row.names = FALSE)
