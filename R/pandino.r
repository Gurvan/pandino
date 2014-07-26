#' pandino.
#'
#' @name pandino
#' @docType package
getURIs <- function(uris, ..., multiHandle = getCurlMultiHandle(), .perform = TRUE)
{
  content = list()
  curls = list()

  for(i in uris) {
    curl = getCurlHandle()
    content[[i]] = basicTextGatherer()
    opts = curlOptions(URL = i, writefunction = content[[i]]$update, ...)    
    curlSetOpt(.opts = opts, curl = curl)
    multiHandle = push(multiHandle, curl)
  }

  if(.perform) {
     complete(multiHandle)
     lapply(content, function(x) x$value())
   } else {
     return(list(multiHandle = multiHandle, content = content))
   }
}

getPicsURL <- function(names_) {
	uris <- paste('https://twitter.com/', names_, '/profile_image/', sep="")
	pics_urls <- getURIs(uris)
	pics_urls<-gsub("<html><body>You are being <a href=\"", "", pics_urls)
	pics_urls<-gsub("\">redirected</a>.</body></html>", "", pics_urls)
	pics_urls<-gsub("_normal", "_200x200", pics_urls)
	return(pics_urls)
}

setFeatures <- function(features_) {
	
	all_categories<- c("gaming", "comedy", "animals", "film_animation", "science_tech", "travel", "people_blogs", "howto", "entertainment", "sports", "autos", "music", "news_politics", "nonprofit", "education", "movies", "shows")
	all_countries <- c("none", "others", "north_america")
	
	categories <- NULL
	for(i in 1:length(all_categories)) {
		categories <- c(categories, ifelse(is.element(all_categories[i], features_), 1, 0))
	}
	names(categories) <- all_categories
	
	countries <- NULL
	for(i in 1:length(all_countries)) {
		countries <- c(countries, ifelse(is.element(all_countries[i], features_), 1, 0))
	}
	names(countries) <- all_countries
	
	nprom <- ifelse(is.element('nprom', features_), 1, 0)
		
	return(list(categories = categories, countries = countries, nprom = nprom))
}

filter <- function(nprom_, countries_) {
        ids<-NULL
        tmp.countries <- users.countries
		nproms <- names(users.nprom[users.nprom == 1 ])
        #tmp.ids <- users.ids
        ids_none <- NULL
        ids_others <- NULL
        ids_na <- NULL

        if(countries_['none'] == 1) {
                ids_none <- users.ids[tmp.countries == 0]
        }

        if(countries_['others'] == 1) {
                ids_others <- users.ids[tmp.countries == 1]
        }

        if(countries_['north_america'] == 1) {
                ids_na <- users.ids[tmp.countries == 2]
        }

        ids <- c(ids_none, ids_others, ids_na)

        if(nprom_ == 1){
                ids <- intersect(ids, nproms)
        }
        return(ids)
}

metrica <- function(ids_, categories_, speed_) {
	m1 <- as.matrix(percentili[cluster.labels[ids_],]*youtube.share[ids_,]) %*% categories_
	
	w2 <- c(1/4, 1/2, 1/4)		#num_tweets, fraction_of_tweets_containing_youtube_videos, mean_lag
	m2 <- as.matrix(utility.matrix[ids_, 1:3]) %*% w2

	w3 <- c(0.32, 0.18, 0.13, 0.12, 0.23, 0.02)		#followers, friends, avg_no_of_followers_of_friends, fraction_of_tweets_that_are_retweets, number_of_distinct_users_mentioned, fraction_of_tweets_containing_a_hashtag
	m3 <- as.matrix(utility.matrix[ids_, 4:9]) %*% w3
	
	return(m1 *(1/speed_ * m2 + m3))
}

getUsers <- function(features_, n, speed) {
	features <- setFeatures(features_)
	ids <- filter(features$nprom, features$countries)
	
	speed = max(1, min(speed, 7))

	score <- metrica(ids, features$categories, speed)
	names(score) <- ids
	score<-sort(score, decreasing = TRUE)
	score <- 100*score/score[1]
	data <- cbind(users.final[names(score),], score = score)
	
	n = max(5, min(n, 30))
	data <- data[1:n,]
	data <- cbind(data, pic_urls = getPicsURL(data$screen_name))
	
	sumFollowers <- sum(data[,'followers'])
	meanFollowers <- sumFollowers/n
	nRT <- sum(data[,'average_retweet_per_tweet'])
	sharingTime <- 1/(data[,'tweets_per_day'] * data[,'frac_tweets_yt'] * rowSums(t(t(data[,8:24]) * features$categories)))
	minSharingTime <- min(sharingTime)
	thirdQsharingTime <- as.numeric(quantile(sharingTime, probs = 0.75))
	data <- data[,c(1:4, 25:26)]
	data_list <- list(data, sumFollowers, meanFollowers, nRT, minSharingTime, thirdQsharingTime)
	return(data_list)
}