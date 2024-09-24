#' CryptoRSI Heatmap
#'
#' Generates a heatmap of the Relative Strength Index (RSI) for a randomly selected
#' subset of cryptocurrencies. This function leverages the `crypto2` and `TTR`
#' packages to fetch cryptocurrency data and calculate RSI values, respectively.
#' The heatmap visualizes RSI values to identify potential overbought or oversold
#' conditions in the crypto market.
#'
#' @title CryptoRSI Heatmap Function
#' @description This function provides a heatmap visualization of RSI values for
#'  a specified number of cryptocurrencies. Selected randomly based on their market
#'  cap ranking, it aims to offer insights into the current market sentiment.
#' @param coin_num An integer specifying the number of coins to display in the heatmap.
#' @param useRank An integer defining the range within which coins are randomly
#'  selected based on their market cap ranking.
#' @param n An integer indicating the number of periods for calculating moving
#'  averages in the RSI computation.
#' @param useRankPlot A boolean that determines if the x-axis should plot ranks
#'  instead of sequential numbers.
#' @param OutputData A boolean that decides if the function should return the final
#'  plot data table.
#'
#' @importFrom crypto2 crypto_list crypto_history
#' @importFrom TTR RSI
#' @importFrom assertthat assert_that
#' @importFrom stats median
#'
#' @return If `OutputData` is TRUE, returns a data frame with symbols,
#'  ranks (or sequential numbers), RSI values, and colors for plotting.
#'  Otherwise, displays a heatmap plot.
#'
#' @export CryptoRSIheatmap
#' @author Satoshi Kume
#'
#' @examples
#' \dontrun{
#' CryptoRSIheatmap(coin_num = 200, useRank = 1000, n = 21,
#'         useRankPlot = TRUE, OutputData = FALSE)
#'}
#'

CryptoRSIheatmap <- function(coin_num = 200, useRank = 1000, n = 21, useRankPlot = TRUE,
                             OutputData = FALSE){

assertthat::assert_that(coin_num < useRank, msg = "coin_num must be less than useRank")

cat("Obtaining the crypto_list... \n")
coins <- crypto2::crypto_list(only_active=TRUE)

#str(coins)
coins <- coins[order(coins$rank),]
coins <- coins[1:useRank,]

res <- sample(nrow(coins), size = coin_num, replace = FALSE)
coins.res <- coins[res[order(res)],]

cat("Obtaining the crypto_history... \n")
coin_hist <- crypto2::crypto_history(coins.res,
                                     start_date=gsub("-", "", lubridate::date(Sys.Date())-n-10),
                                     end_date=gsub("-", "", lubridate::date(Sys.Date())-1))
coin.df <- data.frame(coin_hist)
#head(coin.df); str(coin.df)

results <- data.frame(matrix(NA, nrow=coin_num, ncol=4))
results$X1 <- coins.res$symbol
results$X2 <- seq_len(coin_num)
results$X3 <- coins.res$rank

for(k in seq_len(nrow(coins.res))){
  #k <- 1
  a <- coins.res$symbol[k]
  b <- coin.df[coin.df$symbol == a,]
  if(nrow(b) >= n+5){
  d <- round(TTR::RSI(as.numeric(b$close), n = n), 2)
  results[grepl(coins.res$symbol[k],results$X1),4] <- d[length(d)]
  }
}

#Remove NA
#table(is.na(results$X4))
results <- results[!is.na(results$X4),]
colnames(results) <- c("Symbol", "No", "Rank", "ClosePrice")

if(useRankPlot){
results.u <- results[,-2]
XYlab <- c("Rank", "ClosePrice")
}else{
results.u <- results[,-3]
XYlab <- c("No", "ClosePrice")
}
colnames(results.u) <- c("Symbol", "X", "Y")

#Setting
UpperLimit <- 85
OVERBOUGHT <- 70
STRONG <- 60
NEUTRAL <- 50
WEAK <- 40
OVEZRSOLD <- 30
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
results.u$COL[results.u$Y < OVEZRSOLD] <- "#0072FF95"

#Plot
oldpar <- graphics::par(no.readonly = TRUE)
on.exit(graphics::par(oldpar))
pp <- round(x2*0.01,0)

par(family= "HiraKakuPro-W3", xpd =F, mar=c(5,4,3,2))
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
lab <- c(LowerLimit, OVEZRSOLD, WEAK, NEUTRAL, STRONG, OVERBOUGHT, UpperLimit)
axis(2, at = lab, labels = F)
text(par("usr")[1]-5, lab, labels = lab, srt = 0, pos = 2, xpd = TRUE, cex=1)

#Polygon zone
polygon( c(x1:(x2+pp), rev(x1:(x2+pp))),
         c(rep(LowerLimit-p, length(x1:(x2+pp))), rep(OVEZRSOLD, length(x1:(x2+pp)))),
         col="#0072FF30", border = NA)
polygon( c(x1:(x2+pp), rev(x1:(x2+pp))),
         c(rep(OVEZRSOLD, length(x1:(x2+pp))), rep(WEAK, length(x1:(x2+pp)))),
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

