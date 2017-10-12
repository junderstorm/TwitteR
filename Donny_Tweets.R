#Cran TwitteR link: https://cran.r-project.org/web/packages/twitteR/twitteR.pdf
install.packages("gridExtra")

library(twitteR)
library(RCurl)
library(DescTools)
library(ggplot2)

#the library() just selects the libraries for use - you can also just select them in the right panel if you're using R Studio

require(twitteR)
require(RCurl)

setwd("~/Dropbox/R Directory/Twitter R Scripts/TwitteR Fun")

#navigate to (https://twitter.com/apps/new) create new application and make sure to get a key and secret
#Make sure your access level is set to:  Read, write, and direct messages
#plug in the key and secret to the function below
#setup_twitter_oauth("API key", "API secret", "Access token", "Access secret")

#Authenticate your account
setup_twitter_oauth('API KEYS HERE')

don <- getUser("realdonaldtrump")
don$getId() #Printing out my ID to verify

potus <- getUser("potus44")
potus$getId()
getUser(1536791610) #To verify the correct handle

#Get POTUS (TRUMP)
PotusTweets <- twListToDF(userTimeline("potus", n=1000))
names(PotusTweets)
nrow(PotusTweets)

#Get Obama (POTUS44)
PotusTweets44 <- twListToDF(userTimeline("potus44", n=1000))
names(PotusTweets44)
nrow(PotusTweets44)

#Get RealDonaldTrump
tweets <- userTimeline("realdonaldtrump", n=1000)
#NOTE: @realdonaldtrump has 26.2M Followers as of 3/7/17
length(tweets) #Check the number of tweeet - I only have 29 available

#Convert to a data frame - for TESTING
donny_twee <- twListToDF(tweets)
names(donny_twee)

#Just to clean up a bit let's get the TweetIDs in a more readable format
Tweets <- paste("i",format(donny_twee$id, scientific=FALSE), sep="")
donny_twee["iTweet_Ids"] <- Tweets
donny_twee$iTweet_Ids

#Creating a field that normalizes the favorite counts so that the tweet with the max favs = 1 and min = 0. Everything else is proportinally in between based on fav volums
donny_twee$Normalized_Fav_Count <- (donny_twee$favoriteCount-min(donny_twee$favoriteCount))/(max(donny_twee$favoriteCount)-min(donny_twee$favoriteCount))
PotusTweets$Normalized_Fav_Count <- (PotusTweets$favoriteCount-min(PotusTweets$favoriteCount))/(max(PotusTweets$favoriteCount)-min(PotusTweets$favoriteCount))


#Create a field that combines Favorites and Retweets - let's call this the attention index or ADX
donny_twee$ADX <- donny_twee$favoriteCount + (2*donny_twee$retweetCount)
PotusTweets$ADX <- PotusTweets$favoriteCount + (2*PotusTweets$retweetCount)

#Show the proportion of likes to total followers by tweet
donny_twee$prop <- donny_twee$favoriteCount/26000000
PotusTweets$prop <- PotusTweets$favoriteCount/15900000



names(donny_twee)

attach(donny_twee)
hist(donny_twee$favoriteCount, main="Distirbution of Favorites", xlab = "Favorite Volume", col = "steelblue")

#Desc(favoriteCount~created,donny_twee,plotit=TRUE) let's try the ggplot

#Using Quickplot to get some graphs in there
#qplot(x, y, data=, color=, shape=, size=, alpha=, geom=, method=, formula=, facets=, xlim=, ylim= xlab=, ylab=, main=, sub=)

#Favorite Count by Date
require(gridExtra)
plot1 <- qplot(created,favoriteCount,data=donny_twee,main="@RealDonaldTrump Tweets",xlab="Created Date",ylab="Favorite Count",ylim=c(0,1800000),xlim=c('2017-01-01','2017-03-12'))
plot2 <- qplot(created,favoriteCount,data=PotusTweets,main="@Potus Tweets",xlab="Created Date",ylab="Favorite Count",ylim=c(0,1800000),xlim=c('2017-01-01','2017-03-12'))
plot3 <- qplot(created,favoriteCount,data=PotusTweets44,main="@Potus44 (Obama) Tweets",xlab="Created Date",ylab="Favorite Count",ylim=c(0,1800000),xlim=c('2017-02-15','2017-03-12'))
grid.arrange(plot1, plot2, plot3, ncol=3)

qplot(created,favoriteCount,data=PotusTweets44,main="@Potus44 (Obama) Tweets",xlab="Created Date",ylab="Favorite Count",xlim=c('2017-01-01','2017-03-12'))

#Retweet Count by Date
qplot(created,retweetCount,data=donny_twee,main="Favorite Count by Date")

#ADX by Date
qplot(created,ADX,data=donny_twee,main="Favorite Count by Date")

#Proportion of likes to follwers by Date
require(gridExtra)
plot1 <- qplot(created,prop,data=donny_twee,main="Trump Proportion of favorites to follower count by Date",xlab="Created Date",ylab="Proportion of Favs to total followers")
plot2 <- qplot(created,prop,data=PotusTweets,main="Potus Proportion of favorites to follower count by Date",xlab="Created Date",ylab="Proportion of Favs to total followers")
grid.arrange(plot1, plot2, ncol=2)


#Histogram of the normalized favorite volumes
hist(favoriteCount, main="Normalized Favorite Vales", xlab = "Buckets", col = "red")

# Write CSV in R
write.csv(PotusTweets, file = "Potus.csv")
