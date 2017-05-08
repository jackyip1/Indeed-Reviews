library(syuzhet)    # Sentiment package
library(dplyr)      # Wrangling
library(data.table) # Wrangling
library(ggplot2)    # Graphing
library(tidyr)      # Wrangling

# Load 'reviews.csv' (from Jupyter Notebook)
sentiment_retail<- fread('./reviews.csv')

# Setting theme and color palette for plotting
myTheme <- theme(legend.position="hidden", 
                 panel.background = element_blank(), 
                 panel.grid.major = element_line(colour = "grey"),
                 strip.background = element_rect(fill = "white"),
                 strip.text = element_text(face = "bold"))
palette <- c("#999999", "#d50000", "#3F8428", "#008066", "#FDBB30", "#B3009D", "#333CFF", "#39FF33")

# Concatenate header, comment, pro, con
sentiment_retail$review <- paste(sentiment_retail$header, sentiment_retail$comment, sentiment_retail$pro, sentiment_retail$con, sep=", ")

# Subset to include only company, review, and month
sentiment_retail <- sentiment_retail[, c('company', 'month', 'review')]

# Calculate sentiment scores using Syuzhet's get_sentiment() function
sentiment_retail$sentiment <- get_sentiment(sentiment_retail$review) %>% as.numeric()

# Calculate count of positive and negative sentiment scores
sentiment_retail$pos_ct <- ifelse(sentiment_retail$sentiment > 0, 1, 0)
sentiment_retail$neg_ct <- ifelse(sentiment_retail$sentiment < 0, 1, 0)

# Calculate emotion scores using Syuzhet's get_nrc_sentiment() function
sentiment_retail <- cbind(sentiment_retail, get_nrc_sentiment(sentiment_retail$review))

# Calculate monthly count of positive and negative sentiment scores by company
sentiment_retail_agg <- sentiment_retail %>% 
  group_by(company, month) %>% 
  summarize(positive = sum(pos_ct), negative = sum(neg_ct))

# Calculate monthly mean sentiment scores by company
sentiment_retail_agg <- sentiment_retail %>% 
  group_by(company, month) %>% 
  mutate(negative = mean(negative),
            positive = mean(positive),
            anger = mean(anger),
            anticipation = mean(anticipation),
            disgust = mean(disgust),
            fear = mean(fear),
            joy = mean(joy),
            sadness = mean(sadness),
            surprise = mean(surprise),
            trust = mean(trust))

# Function for normalizing monthly counts to be scaled from 0 to 1 for each company
normalit<-function(m){
  (m - min(m))/(max(m)-min(m))
}

# Add positive_scaled column
sentiment_retail_agg <- sentiment_retail_agg %>%
  group_by(company) %>%
  mutate(positive_scaled = normalit(positive))

# Add negative_scaled column
sentiment_retail_agg <- sentiment_retail_agg %>%
  group_by(company) %>%
  mutate(negative_scaled = normalit(negative))

# Reverse factor orders for company to label company alphabetically from top to bottom
sentiment_retail_agg$company<- factor(sentiment_retail_agg$company,
                                      levels=c('Wegmans',
                                               'Trader Joe\'s',
                                               'Spirit Halloween Super Store',
                                               'QuikTrip',
                                               'Publix',
                                               'HEB',
                                               'Costco Wholesale',
                                               'Build-A-Bear Workshop'))

# Plot heatmap for positive_scaled sentiment
ggplot(sentiment_retail_agg, aes(month, company)) + 
  geom_tile(aes(fill = positive_scaled), colour = "white") + 
  scale_fill_gradient(low = "white", high = "steelblue") +
  scale_x_discrete(limits=1:12) + 
  ggtitle('Sentiment by Company & Month')

# Plot heatmap for negative_scaled sentiment
ggplot(sentiment_retail_agg, aes(month, company)) + 
  geom_tile(aes(fill = negative_scaled), colour = "white") + 
  scale_fill_gradient(low = "white", high = "steelblue") +
  scale_x_discrete(limits=1:12) + 
  ggtitle('Sentiment by Company & Month')

# Change month to numeric
sentiment_retail_agg$month <- as.numeric(sentiment_retail_agg$month)

# Plot emotions over time
emotions <- sentiment_retail_agg %>%
  gather("emotion", "score", 7:16) 

# Reorder factors for emotions
emotions$emotion<- factor(emotions$emotion, levels = c('positive',
                                                       'joy',
                                                       'trust',
                                                       'anticipation',
                                                       'surprise',
                                                       'negative',
                                                       'sadness',
                                                       'fear',
                                                       'disgust',
                                                       'anger'))

# Reverse factor orders for company
emotions$company<- factor(emotions$company,
                                      levels=c('Build-A-Bear Workshop',
                                               'Costco Wholesale',
                                               'HEB',
                                               'Publix',
                                               'QuikTrip',
                                               'Spirit Halloween Super Store',
                                               'Trader Joe\'s',
                                               'Wegmans'))

# Plot monthly mean emotion scores faceted by emotion and company
emotions %>%
  ggplot(aes(month, score, color = company)) +
  geom_line(size = 1) + 
  scale_color_manual(values = colourList) +
  scale_x_continuous(name = "\nTime", breaks = NULL) +
  scale_y_continuous(name = "Sentiment\n", breaks = seq(0, 10, by=5)) +
  facet_grid(company ~ emotion) + 
  theme(strip.text.y = element_text(angle=30)) +
  myTheme
