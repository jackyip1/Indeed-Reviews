library(data.table)  # Load reviews.csv
library(dplyr)       # Wrangling
library(plyr)        # Wrangling
library(ggplot2)     # Visualization

###############
# Data Cleaning
###############

# reading csv into data.table
rawdata <- fread('reviews.csv')

# remove duplicate observations
rawdata <- unique(rawdata)
class(rawdata[2])
str(rawdata)

# extract year, month, date from fulldate
rawdata$year <- format(as.Date(rawdata$fulldate, format="%B %d, %Y"),"%Y")
rawdata$month <- format(as.Date(rawdata$fulldate, format="%B %d, %Y"),"%m")
rawdata$day <- format(as.Date(rawdata$fullday, format="%B %d, %Y"),"%d")

# remove reviews with NA year/month/day (only 5 observations removed)
rawdata <- rawdata[!is.na(rawdata$year),]
rawdata <- rawdata[!is.na(rawdata$month),]
rawdata <- rawdata[!is.na(rawdata$day),]

# reorder columns
colnames(rawdata)

# remove zip codes from location
m <- regexec("[0-1]{5}$", rawdata$location)
y <- data.frame(regmatches(rawdata$location,m))

# strip state from location
m <- regexec("[A-Z]{2}$", rawdata$location)
y <- regmatches(rawdata$location,m)
y[y=='character(0)'] <- ""
y <- unlist(y)
rawdata$state <- y

# change job title to lower case
rawdata$jobtitle <- sapply(rawdata$jobtitle, tolower)

# write to csv
fwrite(rawdata, "reviews.csv")

#############################
# Review Counts
#############################

# number of reviews by company
reviewbycompany <- rawdata %>% 
  group_by(company) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# plot barplot review count by company
barreviewcountbyfirm <- ggplot(reviewbycompany, aes(x = reorder(company, count), y = count)) +
  geom_bar(stat='identity') +
  xlab('Company') +
  ylab('Review Counts') +
  ggtitle('Review Counts By Company') +
  coord_flip()

# number of reviews by state
reviewbystate <- rawdata %>% 
  group_by(state) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# plot barplot review count by state
barreviewcountbystate <- ggplot(reviewbystate, aes(x = reorder(state, count), y = count)) +
  geom_bar(stat='identity') +
  xlab('State') +
  ylab('Review Counts') +
  ggtitle('Review Counts By State') +
  coord_flip()

# number of reviews by year
reviewbyyear <- rawdata %>% 
  group_by(year) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# plot barplot review count by year
barreviewcountbyyear <- ggplot(reviewbyyear, aes(x = reorder(year, count), y = count)) +
  geom_bar(stat='identity') +
  xlab('Year') +
  ylab('Review Counts') +
  ggtitle('Review Counts By Year') +
  coord_flip()

# number of reviews by month
reviewbymonth <- rawdata %>% 
  group_by(month) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# plot barplot review count by month
barreviewcountbymonth <- ggplot(reviewbymonth, aes(x = reorder(month, count), y = count)) +
  geom_bar(stat='identity') +
  xlab('Month') +
  ylab('Review Counts') +
  ggtitle('Review Counts By Month') +
  coord_flip()

# number of reviews by day
reviewbyday <- rawdata %>% 
  group_by(day) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# plot barplot review count by day
barreviewcountbyday <- ggplot(reviewbyday, aes(x = reorder(day, count), y = count)) +
  geom_bar(stat='identity') +
  xlab('Day') +
  ylab('Review Counts') +
  ggtitle('Review Counts By Day') +
  coord_flip()

# number of reviews by rating
reviewbyrating <- rawdata %>% 
  group_by(rating) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# plot barplot review count by rating
barreviewcountbyrating <- ggplot(reviewbyrating, aes(x = reorder(rating, count), y = count)) +
  geom_bar(stat='identity') +
  xlab('Rating') +
  ylab('Review Counts') +
  ggtitle('Review Counts By Rating') +
  coord_flip()

# number of reviews by job title
reviewbytitle <- rawdata %>% 
  group_by(jobtitle) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# plot barplot review count by job title (Not Recommended)

#############################
# relationships with rating #
#############################

# average rating by year
avgratingbyyear <- rawdata %>% 
  group_by(year) %>% 
  summarize(avg = mean(rating)) %>% 
  arrange(desc(avg))

# plot barplot average rating by year
baravgratingbyyear <- ggplot(avgratingbyyear, aes(x = reorder(year, avg), y = avg)) +
  geom_bar(stat='identity') +
  xlab('Year') +
  ylab('Rating') +
  ggtitle('Average Rating by Year') +
  coord_flip()

# average rating by month
avgratingbymonth <- rawdata %>% 
  group_by(month) %>% 
  summarize(avg = mean(rating)) %>% 
  arrange(desc(avg))

# plot barplot average rating by month
baravgratingbymonth <- ggplot(avgratingbymonth, aes(x = reorder(month, avg), y = avg)) +
  geom_bar(stat='identity') +
  xlab('Month') +
  ylab('Rating') +
  ggtitle('Average Rating by Month') +
  coord_flip()

# average rating by day
avgratingbyday <- rawdata %>% 
  group_by(day) %>% 
  summarize(avg = mean(rating)) %>% 
  arrange(desc(avg))

# plot barplot average rating by day
baravgratingbyday <- ggplot(avgratingbyday, aes(x = reorder(day, avg), y = avg)) +
  geom_bar(stat='identity') +
  xlab('Day') +
  ylab('Rating') +
  ggtitle('Average Rating by Day') +
  coord_flip()

# average rating by company
avgratingcompany <- rawdata %>% 
  group_by(company) %>% 
  summarize(avg = mean(rating)) %>% 
  arrange(desc(avg))

# plot barplot average rating by company
baravgratingbyfirm <- ggplot(avgratingcompany, aes(x = reorder(company, avg), y = avg)) +
  geom_bar(stat='identity') +
  xlab('Company') +
  ylab('Rating') +
  ggtitle('Average Rating by Company') +
  coord_flip()

# average rating by state
avgratingstate <- rawdata %>% 
  group_by(state) %>% 
  summarize(avg = mean(rating)) %>% 
  arrange(desc(avg))

# plot barplot average rating by state
baravgratingbystate <- ggplot(avgratingstate, aes(x = reorder(state, avg), y = avg)) +
  geom_bar(stat='identity') +
  xlab('State') +
  ylab('Rating') +
  ggtitle('Average Rating by State') +
  coord_flip()

# get top 50 job titles by count
top50titlecount <- rawdata %>%
  group_by(jobtitle) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count)) %>% 
  top_n(50)

# subset rawdata by top 50 job titles
rawdatatop50titlecount <- rawdata[rawdata$jobtitle %in% rawdatatop50titlecount$jobtitle]

# average rating by top 50 job titles
avgratingtitle <- rawdatatop50titlecount %>% 
  group_by(jobtitle) %>% 
  summarize(count = n(), avg = mean(rating)) %>% 
  arrange(desc(count, avg))

# plot barplot average rating by top 50 job titles
baravgratingbytitle <- ggplot(avgratingtitle, aes(x = reorder(jobtitle, avg), y = avg)) +
  geom_bar(stat='identity') +
  xlab('Title') +
  ylab('Rating') +
  ggtitle('Average Rating by Title') +
  coord_flip()

#############################
# Heatmaps 
#############################

# average rating by month + company
avgratingmonthfirm <- rawdata %>% 
  group_by(company, month) %>% 
  summarize(avg = mean(rating)) %>% 
  arrange(desc(avg))

# remove NAs from averageratingmonthfirm
avgratingmonthfirm <- avgratingmonthfirm[!is.na(avgratingmonthfirm$month),]

# plot averageratingmonthfirm heatmap
heatmonthfirm <- ggplot(avgratingmonthfirm, aes(month, company)) + 
  geom_tile(aes(fill = avg), colour = "white") + 
  scale_fill_gradient(low = "white", high = "steelblue") +
  ggtitle('Rating by Company & Month')

# average rating by month + title
avgratingmonthtitle <- rawdatatop50titlecount %>% 
  group_by(jobtitle, month) %>% 
  summarize(avg = mean(rating)) %>%
  arrange(desc(avg))

# remove NAs from averageratingmonthtitle
avgratingmonthtitle <- avgratingmonthtitle[!is.na(avgratingmonthtitle$month),]

# plot averageratingmonthtitle heatmap
heatmonthtitle <- ggplot(avgratingmonthtitle, aes(month, jobtitle)) + 
  geom_tile(aes(fill = avg), colour = "white") + 
  scale_fill_gradient(low = "white", high = "steelblue") +
  ggtitle('Rating by Title & Month')

