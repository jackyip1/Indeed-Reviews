library(tm)           # Create corpus
library(RColorBrewer) # Set color palette for wordclouds
library(wordcloud)    # Create wordcloud
library(wordcloud2)   # Create wordcloud

# Prepare reviews to be assigned to a corpus
reviews_neg <- sentiment_retail[sentiment_retail$sentiment < -2 ,]$review
reviews_pos <- sentiment_retail[sentiment_retail$sentiment > 2 ,]$review

# Assign reviews to corpus (Note: replace reviews_pos with reviews_neg to create new wordcloud)
corpus <- Corpus(VectorSource(reviews_pos))

# Convert the text to lower case
corpus <- tm_map(corpus, content_transformer(tolower))
# Remove numbers
corpus <- tm_map(corpus, removeNumbers)
# Remove common stopwords
corpus <- tm_map(corpus, removeWords, stopwords("english"))
# Remove specific stop word
corpus <- tm_map(corpus, removeWords, c("Publix")) 
# Remove punctuations
corpus <- tm_map(corpus, removePunctuation)
# Eliminate extra white spaces
corpus <- tm_map(corpus, stripWhitespace)
# Note: For simplicity, text stemming was not performed.

# Plot using wordcloud package
wordcloud(corpus, scale = c(5, 0.5), min.freq=1, max.words = 50,random.order = FALSE, rot.per = 0.35,
          use.r.layout = FALSE, colors = brewer.pal(6,"Dark2"))

# Alternative wordcloud using wordcloud2 package
# Create TermDocumentMatrix from corpus
tdm <- TermDocumentMatrix(corpus)
# Convert tdm to a matrix
m <- as.matrix(tdm)
# Sort words by frequency
v <- sort(rowSums(m),decreasing = TRUE)
# Create dataframe with words and their frequency
corpus2 <- data.frame(word=names(v),freq = v)
# Plot wordcloud
wordcloud2(corpus2, color = "random-dark",size = 0.8, shape = "circle", backgroundColor = "white")

# Subset dataframe for less frequent words
corpus3 <- corpus2[corpus2$freq >= 1 & corpus2$freq <= 3,]
# Plot wordcloud
wordcloud2(corpus3, color = "random-dark",size = 0.1, shape = "square", backgroundColor = "white") 

