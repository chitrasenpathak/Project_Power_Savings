rm(list = ls())

install.packages("lubridate")
library(dplyr)
library(lubridate)

Ext_temp<- read.csv(file.choose())


#Ext_temp1<-Ext_temp
str(Ext_temp)
Ext_temp$Datenew<-strptime(Ext_temp$Date,format="%d-%m-%Y")
#Ext_temp$Datenew<-as.character(Ext_temp$Date,format="%Y-%m-%d")

str(Ext_temp)
Ext_temp$Timenew<-as.character(Ext_temp$Time,format="%H:%M")
Ext_temp$Date_Time<-as.character(paste(Ext_temp$Datenew, Ext_temp$Timenew),format="%Y-%m-%dT%H:%M:%OS")
str(Ext_temp)
Ext_temp$Date_Time<-as_datetime(Ext_temp$Date_Time,format="%Y-%m-%d %H:%M")

str(Ext_temp)
df<-data.frame(table(cut(Ext_temp$Date_Time, breaks = "15 mins")))
df$Date_Time<-df$Var1
df$Var1<-NULL

install.packages("zoo")
library(zoo)
df1<-merge(x=df,y=Ext_temp,by="Date_Time",all.x = TRUE)
df1$T1<-na.locf(df1$Temp_C,na.rm=FALSE,rev = FALSE)
df1$H1<-na.locf(df1$Humidity_P,na.rm=FALSE,rev = FALSE)
df1$W1<-na.locf(df1$Weather,na.rm=FALSE,rev = FALSE)

df1$Date<-NULL
df1$Freq<-NULL
df1$Time<-NULL
df1$Temp_C<-NULL
df1$Weather<-NULL
df1$Humidity_P<-NULL
df1$Datenew<-NULL
df1$Timenew<-NULL
View(df1)

#df1$Date_Time[as.Date(df$Date_Time)>='2016-11-01' && as.Date(df$Date_Time)<'2017-02-07']
df1$Date_Time[as.Date(df$Date_Time)>='2016-11-01' && as.Date(df$Date_Time)<'2017-02-07']
df2<-subset(df1,as.Date(df$Date_Time)<=as.Date('2017-02-06'))
df2$Date<-as.Date(df2$Date_Time)
df2$time<-ymd_hms(df2$Date_Time)
#df2$time<-NULL
df2$time<-format(df2$time,"%H%M")

View(df2)
str(df2)
