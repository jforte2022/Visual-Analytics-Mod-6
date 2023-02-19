library(RCurl)
library(dplyr)
library(RJSONIO)
library(sqldf)
library(tidyverse)
library(lubridate)

fileURL <- "https://opendata.maryland.gov/resource/rqid-652u.json"

mydata <- fromJSON(fileURL)
mydata2 <- map(mydata, as.list)
mydata2 <- map_df(mydata2, flatten)
df1 <- data.frame(mydata2, stringsAsFactors = FALSE)

df1$date <- as.Date(df1$date)
df1$day_of_week <- wday(df1$date, label = TRUE, abbr = FALSE)
df1$day_of_week <- as.character(df1$day_of_week)
df1$X..computed_region_r4de_cuuv <- as.numeric(df1$X..computed_region_r4de_cuuv)
df1$latitude <- as.numeric(df1$latitude)
df1$longitude <- as.numeric(df1$longitude)
names(df1)[names(df1) == "X..computed_region_r4de_cuuv"] <- "computed_region_r4de_cuuv"
df1 <- df1[!is.na(df1$cc_number), ]

df1$accident_type <- gsub("pd", "Property Damage", df1$accident_type)
df1$accident_type <- gsub("PD", "Property Damage", df1$accident_type)
df1$accident_type <- gsub("Property Damage Crash", "Property Damage", df1$accident_type)

df1$accident_type <- gsub("PI", "Personal Injury", df1$accident_type)
df1$accident_type <- gsub("Injury Crash", "Personal Injury", df1$accident_type)
df1$accident_type <- gsub("IS", "Personal Injury", df1$accident_type)

df1$accident_type <- gsub("F", "Fatal Crash", df1$accident_type)

pieData <- sqldf("SELECT COUNT(accident_type) FROM df1 GROUP BY accident_type")
pieData <- cbind(c("Fatality", "Personal Injury", "Property Damage"), pieData$`COUNT(accident_type)`)
colnames(pieData) <- c("AccidentType", "Count")
pieData <- as.data.frame(pieData)
pieData$Count <- as.numeric(pieData$Count)
pie(pieData$Count, col = c("red", "orange", "yellow"), labels = pieData$AccidentType)