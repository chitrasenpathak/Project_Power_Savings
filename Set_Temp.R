rm(list = ls())
library(zoo)
library(lubridate)
Set_temp<- read.csv(file.choose())
#Removing unwanted columns
Set_temp <- Set_temp[Set_temp$Parameter %in% "Edge1 SetPoint Temp",]
Set_temp<- Set_temp[,-c(1,2)]
str(Set_temp)
#Converting & Rounding time into POSXlt format
Set_temp$changedate <- as.character(Set_temp$changedate,format="%Y-%m-%d %H:%M")
Set_temp$changedate <- as_datetime(Set_temp$changedate,format="%Y-%m-%d %H:%M")
Set_temp$t1<-round_date(Set_temp$changedate,unit="15 minutes")
Set_temp$Date_Time<-Set_temp$t1
Set_temp$t1<-NULL
#Filtering dates into required range
Set_temp$Date_Time<-as.factor(Set_temp$Date_Time)
Set_temp$Date_Time[as.Date(Set_temp$Date_Time)>='2016-11-01' && as.Date(Set_temp$Date_Time)<'2017-02-07']
Set_temp<-subset(Set_temp,as.Date(Set_temp$Date_Time)<=as.Date('2017-02-06'))

#merging with external temp data.
df3<-merge(x=df2,y=Set_temp,by="Date_Time",all.x = TRUE)

#filling up missing values of Set temperature
df3$changed_value<-na.locf(df3$changed_value,na.rm=FALSE,rev = FALSE)
df3$Parameter<-NULL
df3$changedate<-NULL

#Remove duplicate rows based on date and time vairable
df3<-df3[!duplicated(df3$Date_Time),]
