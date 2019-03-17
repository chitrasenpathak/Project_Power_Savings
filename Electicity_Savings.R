library(dplyr) # Data Manipulation
library(ggplot2) # Visualization
library(scales) # Visualization
library(caTools) # Prediction: Splitting Data
library(car) # Prediction: Checking Multicollinearity
library(ROCR) # Prediction: ROC Curve
library(e1071) # Prediction: SVM, Naive Bayes, Parameter Tuning
library(rpart) # Prediction: Decision Tree
library(rpart.plot) # Prediction: Decision Tree
library(randomForest) # Prediction: Random Forest
library(caret) # Prediction: k-Fold Cross Validation
library(stats)
library(Hmisc)
#Reading the Raw Data
rawdata<-read.csv(file.choose())

#Storing the X's in a vector
edge1_xs <- c("Edge1 Min Temp","Edge1 Max Temp","Edge1 Min Humidity","Edge1 Max Humidity","Edge1 IR1 Duration","Edge1 IR1 DI Duration","Edge1 IR1 Manual Status","Edge1 IR1 status change count","Edge1 IR1 DI status change count","Edge1 IR1 Override")

#Filtering only the required X's Data
dummy <- rawdata[rawdata$channel_name %in% edge1_xs,]
dummy <- as.data.frame(dummy[,-c(2,100,101,102,103,104,105)])
#head(dummy)
#colSums(is.na(dummy)|dummy=='-'|dummy==0)


#Stacking up variables by column
install.packages("reshape2")
library(reshape2)
data <- melt(dummy, id.vars=1:2)

#Ordering up variables by channel and reading_date column
newdata <- data[order(data$channel_name,data$readingdate),]
newdata$value  <- as.integer(newdata$value)

#Pivot the data from row to columns
pivotdata<-dcast(newdata, readingdate + variable ~ channel_name, value.var="value", fun.aggregate=sum)

#Replace X_ for time variable from dataframe
pivotdata$variable<-gsub("X_","",pivotdata$variable)

#pivotdata$Date_Temp<-NULL
pivotdata$Date_Temp<-as.Date(pivotdata$readingdate,format="%d-%m-%Y")

#Rename date and time
colnames(pivotdata)[colnames(pivotdata)=="Date_Temp"] <- "Date"
colnames(pivotdata)[colnames(pivotdata)=="variable"] <- "time"
pivotdata$Date<-as.Date(pivotdata$Date)

#Merge Pivotdata and DF3

FinalDF <- merge(pivotdata,df3,by=c("Date","time"),no.dups = TRUE)

#Convert % and Degree to numeric and multiply by 1000
FinalDF$H2<-as.numeric(sub("%","",FinalDF$H1))*1000
FinalDF$T2<-as.numeric(substr(FinalDF$T1,1,3))*1000

#Remove unwanted variables from the dataframe
FinalDF$readingdate<-NULL
FinalDF$T1<-NULL
FinalDF$H1<-NULL

#Hot encoding for Weather variable

dmy<-dummyVars("~W1",data=FinalDF)
trsf<-data.frame(predict(dmy,newdata=FinalDF))


#Combine 2 dataframes 
FinalDF1<-cbind(FinalDF,trsf)

#summary(FinalDF$`Edge1 IR1 DI Duration`)
#boxplot(FinalDF)


View(FinalDF1)

#str(FinalDF$W1)

#Remove all rows Zero and NA from the dataframe
#library(plyr)
#FinalDF<-(all.zero <- FinalDF[!apply(FinalDF[, -c(1,2)], 1, function(row) all(row == 0)), ])
#FinalDF <- FinalDF[complete.cases(FinalDF[,c(3:10)]),]

#Check for missing values
colSums(is.na(FinalDF) & FinalDF=="-" & FinalDF==0)
