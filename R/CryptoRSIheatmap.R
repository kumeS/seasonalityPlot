#' CryptoRSI Heatmap Function
#'
#' Generates a heatmap of the Relative Strength Index (RSI) for a randomly selected
#' subset of cryptocurrencies. This function uses the `crypto2` and `TTR` packages
#' to fetch cryptocurrency data and calculate RSI values, respectively. The heatmap
#' visualizes RSI values to identify potential overbought or oversold conditions in
#' the crypto market.
#'
#' @title CryptoRSI Heatmap Function
#' @description This function generates a heatmap of RSI values for a randomly 
#'    selected subset of cryptocurrencies. The coins are chosen based on their market 
#'    cap ranking, and the function provides insights into market sentiment using RSI. 
#'    It allows for visualizing potential overbought or oversold conditions.
#' @param coin_num An integer specifying the number of coins to display in the 
#'    heatmap. Must be less than the value of `useRank`.
#' @param useRank An integer defining the range within which coins are randomly 
#'    selected based on their market cap ranking. Defaults to 1000.
#' @param n An integer indicating the number of periods for calculating moving 
#'    averages in the RSI computation. Defaults to 21.
#' @param minDataPoints An integer specifying the minimum number of data points 
#'    required for each coin. Defaults to `n + 5`.
#' @param useRankPlot A boolean that determines if the x-axis should plot ranks 
#'    instead of sequential numbers. Defaults to TRUE.
#' @param OutputData A boolean that decides if the function should return the 
#'    final plot data table or only display the heatmap plot. Defaults to FALSE.
#'
#' @importFrom crypto2 crypto_list crypto_history
#' @importFrom TTR RSI
#' @importFrom assertthat assert_that
#' @importFrom stats median
#'
#' @return If `OutputData` is TRUE, returns a data frame with symbols, ranks (or sequential numbers), RSI values, and colors for plotting. Otherwise, displays a heatmap plot.
#'
#' @export CryptoRSIheatmap
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#'
#' # A heatmap of 200 coins using 21 days RSI
#' CryptoRSIheatmap(coin_num = 200, n = 21)
#'
#' # A heatmap of 300 coins using 90 days RSI
#' CryptoRSIheatmap(coin_num = 300, n = 90)
#' }

CryptoRSIheatmap <- function(coin_num = 200, 
                             useRank = 1000, 
                             n = 21, 
                             minDataPoints = NULL,
                             useRankPlot = TRUE,
                             OutputData = FALSE){

# Ensure that coin_num is less than useRank
assertthat::assert_that(coin_num < useRank, msg = "coin_num must be less than useRank")
if (is.null(minDataPoints)) {
  minDataPoints <- n + 5
}

cat("Obtaining the crypto_list... \n")
#install.packages("crypto2")
#coins <- crypto2::crypto_list(only_active=TRUE, add_untracked=F)
#coin_Rank <- crypto2::crypto_history(coins,
#                                     start_date=gsub("-", "", lubridate::date(Sys.Date())-1),
#                                     end_date=gsub("-", "", lubridate::date(Sys.Date())))  

#Read
coins <- readRDS(system.file("extdata", "coin_Rank_v2.Rds", package = "seasonalityPlot"))
#coins <- crypto2::crypto_list(only_active=TRUE)
#head(coins)

#str(coins)
#coins <- coins[order(coins$rank),]
coins <- coins[!(coins$market_cap %in% c("USDT", "USDC", "FDUSD")),]
coins$rank <- 1:nrow(coins)
#head(coins)

coins <- coins[1:useRank,]
res <- sample(nrow(coins), size = coin_num, replace = FALSE)
coins.res <- coins[res[order(res)],]

cat("Obtaining the crypto_history... \n")
coin_hist <- crypto2::crypto_history(coins.res,
                                     start_date=gsub("-", "", lubridate::date(Sys.Date())-n-10),
                                     end_date=gsub("-", "", lubridate::date(Sys.Date())-1))
coin.df <- data.frame(coin_hist)
#head(coin.df); str(coin.df); str(coin_hist)
#length(unique(coin.df$symbol))

results <- data.frame(matrix(NA, nrow=coin_num, ncol=4))
results$X1 <- coins.res$symbol
results$X2 <- seq_len(coin_num)
results$X3 <- coins.res$rank
#head(results)
#dim(results)

cat("Obtaining the RIS values \n")
for(k in seq_len(nrow(coins.res))){
  #k <- 1
  a <- coins.res$symbol[k]
  b <- coin.df[coin.df$symbol == a,]
  #if(nrow(b) >= n+5){
  #d <- round(TTR::RSI(as.numeric(b$close), n = n), 2)
  #results[grepl(coins.res$symbol[k],results$X1),4] <- d[length(d)]
  #}
  
  #v1.3.1
  if (nrow(b) >= minDataPoints) {
  d <- round(TTR::RSI(as.numeric(b$close), n = n), 2)
  results[grepl(coins.res$symbol[k], results$X1), 4] <- d[length(d)]
  }
}
#dim(results)
#results

#Remove NA
#table(is.na(results$X4))
results <- results[!is.na(results$X4),]
colnames(results) <- c("Symbol", "No", "Rank", "ClosePrice")
#head(results)
#dim(results)
#results

if(useRankPlot){
results.u <- results[,-2]
XYlab <- c("Rank", "ClosePrice")
}else{
results.u <- results[,-3]
XYlab <- c("No", "ClosePrice")
}
colnames(results.u) <- c("Symbol", "X", "Y")
#head(results.u)

#Setting
UpperLimit <- 85
OVERBOUGHT <- 70
STRONG <- 60
NEUTRAL <- 50
WEAK <- 40
OVERSOLD <- 30
LowerLimit <- 15
x1 <- 0
x2 <- max(results.u$X)+1
p <- 3

#Normalized
results.u$Y[results.u$Y > UpperLimit] <- UpperLimit
results.u$Y[results.u$Y < LowerLimit] <- LowerLimit

#Color
results.u$COL <- NA
#head(results.u)
results.u$COL <- "#FF000095"
results.u$COL[results.u$Y < OVERBOUGHT] <- "#FF000040"
results.u$COL[results.u$Y < STRONG] <- "#7E7E7E30"
results.u$COL[results.u$Y < WEAK] <- "#0072FF40"
results.u$COL[results.u$Y < OVERSOLD] <- "#0072FF95"

cat("Obtaining the CryptoRSI Heatmap \n")

#Plot
oldpar <- graphics::par(no.readonly = TRUE)
on.exit(graphics::par(oldpar))
pp <- round(x2*0.01,0)

par(family= "HiraKakuPro-W3", xpd =F, mar=c(5,4,3,2), mgp = c(2.5, 1, 0))
plot(results.u$X, results.u$Y,
     ylim = c(LowerLimit-p, UpperLimit+p),
     xlim = c(x1, x2+pp),
     xlab = XYlab[1], ylab = XYlab[2],
     type = "b", col = "white",
     #xaxt = "n",
     yaxt = "n",
     cex.lab=1.25,
     main = paste0("CryptoRSI Heatmap: ", nrow(results.u), " coins"),
     xaxs="i", yaxs="i")

#X-axis: No-setting
#Y-axis
lab <- c(LowerLimit, OVERSOLD, WEAK, NEUTRAL, STRONG, OVERBOUGHT, UpperLimit)
axis(2, at = lab, labels = F)
text(par("usr")[1]-5, lab, labels = lab, srt = 0, pos = 2, xpd = TRUE, cex=1)

#Polygon zone
polygon( c(x1:(x2+pp), rev(x1:(x2+pp))),
         c(rep(LowerLimit-p, length(x1:(x2+pp))), rep(OVERSOLD, length(x1:(x2+pp)))),
         col="#0072FF30", border = NA)
polygon( c(x1:(x2+pp), rev(x1:(x2+pp))),
         c(rep(OVERSOLD, length(x1:(x2+pp))), rep(WEAK, length(x1:(x2+pp)))),
         col="#0072FF15", border = NA)
polygon( c(x1:(x2+pp), rev(x1:(x2+pp))),
         c(rep(STRONG, length(x1:(x2+pp))), rep(OVERBOUGHT, length(x1:(x2+pp)))),
         col="#FF000010", border = NA)
polygon( c(x1:(x2+pp), rev(x1:(x2+pp))),
         c(rep(OVERBOUGHT, length(x1:(x2+pp))), rep(UpperLimit+p, length(x1:(x2+pp)))),
         col="#FF000020", border = NA)

#Median line
abline(h=stats::median(results.u$Y), lwd=2, lty=2, col="grey")

#Plot points
points(results.u$X, results.u$Y,
       col=results.u$COL, bg=results.u$COL, pch=21, cex=1.25)

#Output
if(OutputData){
return(results.u)
}

}

