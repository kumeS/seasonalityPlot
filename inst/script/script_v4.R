library(quantmod)
library(magrittr)
library(dygraphs)
library(plotrix)
library(htmltools)

#Symbols	: a character vector specifying the names of each symbol to be loaded
#StartYear
#EndYear

seasonPlot <- function(Symbols,
                       StartYear=2000,
                       EndYear=2020,
                       Save=FALSE,
                       LineColor=1){

}

#Symbols="SPY"
#Symbols="BTC-USD"
#Symbols="ETH-USD"

oldpar <- graphics::par(no.readonly = TRUE)
on.exit(graphics::par(oldpar))

error <- try(quantmod::getSymbols(Symbols), silent=T)
if(class(error) == "try-error"){return(message("Warning: No poper value of Symbols"))}
if((StartYear - EndYear) >= 0){return(message("Warning: No poper value of StartYear or EndYear"))}

Date <- c(paste0(StartYear, "-01-01"), paste0(EndYear, "-12-31"))
Dat <- quantmod::getSymbols(Symbols, src = "yahoo", verbose = T, auto.assign=FALSE, from = Date[1], to=Date[2])
colnames(Dat) <- c("Open", "High", "Low", "Close", "Volume", "Adjusted")
#head(Dat); str(Dat)
Date00 <- range(as.numeric(substr(index(Dat), start=1, stop = 4)))
if((Date00[1] - Date00[2]) >= 0){return(message("Warning: No poper value of StartYear or EndYear"))}

#Plot All
Dat[,4] %>%
  dygraphs::dygraph(main = paste0(Symbols, " Close Price: ",  Date00[2]-Date00[1], "-years")) %>%
  dygraphs::dySeries("Close", label = "Dat") %>%
  dygraphs::dyRangeSelector(height = 40)

YN <- askYesNo("Do you want to proceed to the next step?")
if(!YN){
  return(meassage("Finished!!"))
}else{
  grDevices::dev.off()
}

#Create DF
Dat00 <- data.frame(Date=index(Dat), Dat[,c(4)], row.names=seq_len(nrow(Dat)))
#head(Dat00)

#Organize data
Dat00$Year <- substr(Dat00$Date, start=1, stop=4)
Dat00$Month <- substr(Dat00$Date, start=6, stop=7)
Dat00$Week <- strftime(Dat00$Date, format = "%V")
Dat00$Year.Week <- paste0(Dat00$Year, Dat00$Week)
Dat00$Julian <- as.numeric(strftime(Dat00$Date, format = "%j"))
Dat00$Day <- sub("-", "", substring(Dat00$Date, 6, 10))
#head(Dat00); tail(Dat00); str(Dat00)

#combine
Dat01 <- data.frame(matrix(NA, nrow=366, ncol=Date00[2]-Date00[1]+2))
colnames(Dat01) <- c("Date", paste0("Y", Date00[1]:Date00[2]))
Dat01$Date <- 1:366
#head(Dat01)

#Organize data by date, year
for(m in 2:ncol(Dat01)){
#m <- 2
a <- Dat00[Dat00$Year == sub("^Y", "", colnames(Dat01)[m]),]
#head(a)
Dat01[c(a$Julian),m] <- a$Close
}
#head(Dat01)

#more that 366/2 days
Dat02 <- Dat01[, as.vector(apply(Dat01,2, function(x) sum(is.na(x))) < 366/2)]
#head(Dat02)

if(any(apply(Dat02, 2, function(x) sum(is.na(x))) > 50)){
for(m in 2:ncol(Dat02)){
#m <- 3
a <- Dat02[,m]
#head(a)
SUM <- sum(is.na(a))
if(SUM == 0){
  Dat02[,m] <- a
}else{
  b <- a[!is.na(a)]
  b <- c(b, rep(NA, SUM))
  Dat02[,m] <- b
}}
}

Years <- colnames(Dat02)[2:ncol(Dat02)]
Dat03 <- Dat02[as.vector(apply(Dat02, 1, function(x) sum(is.na(x)))) < diff(Date00)*0.6, ]
#as.vector(apply(Dat02, 1, function(x) sum(is.na(x))))
#as.vector(apply(Dat03, 1, function(x) sum(is.na(x))))
#head(Dat03)

#Set the first day of the year as "0%".
for(m in 2:ncol(Dat03)){
#m <- 2
d <- Dat03[,m]
Dat03[,m] <- d/d[!is.na(d)][1]*100 - 100
}
#head(Dat03)

#Delete the days with no data and connect the data
Dat04 <- data.frame(Date=1:nrow(Dat03))
Dat04[,Years] <- NA
for(m in 2:ncol(Dat04)){
#m <- 2
e <- Dat03[,m][!is.na(Dat03[,m])]
Dat04[,m] <- c(e, rep(NA, nrow(Dat03)-length(e)))
}
#tail(Dat04)

#Delete rows with 2 or more missing numbers
Dat04$MissingNum <- sapply(data.frame(t(Dat04[,-1])), function(x) sum(is.na(x)))
Dat04 <- Dat04[c(Dat04$MissingNum < 2),]
#tail(Dat04)

Dat05 <- Dat04
#colnames(Dat05); dim(Dat04)

#図 2. 2000-2020年 Dat のSeasonality
Main <- "図 2. 2000-2020年 Dat のSeasonality"
Y <- c(8:28)
#head(Dat04[,c(Y)])
Dat04$Mean <- NA
Dat04$Mean <- apply(data.frame(Dat04[,c(Y)]), 1, function(x) mean(x[!is.na(x)]))

COL <- "blue1"
St <- Dat04$Mean; St00 <- St[!is.na(St)]
par(family="HiraKakuProN-W3", lwd=1, xpd=F, cex=1, mgp=c(0.5, 1, 0), mai=c(0.5, 0.75, 0.5, 0.5))
plot(St, type="n", axes = F, xlab="© 2021 京橋のバイオインフォマティシャンの日常 by skume",
     ylab="", cex.lab=0.75, xlim=c(0,nrow(Dat04)),
     ylim=c(min(St00) - (max(St00)- min(St00))*0.1, max(St00) + (max(St00)- min(St00))*0.15),
     xaxs="i", yaxs="i", main=Main)
axis(side=2, labels=paste0(seq(-30, 30, by=1), "%"), at=seq(-30, 30, by=1), las=2)
abline(v=seq(0, nrow(Dat04), length.out = 13), col="grey", lty=3, lwd=0.5)
abline(h=seq(-30, 30, by=1), col="black", lty=1, lwd=0.3)
lines(St, col=COL, lwd=1.2)
plotrix::boxed.labels(seq(0, nrow(Dat04), length.out = 13)[1:12]+10,  min(St00) - (max(St00)- min(St00))*0.05,
                      month.abb, cex=0.7, bg = "grey20", xpad = 1.2, ypad = 1.2)
legend("topleft", legend="SPDR S&P500 ETF", col=COL, lwd=1, cex=0.7)
quartz.save(file = paste0("./Dat_02.png"), type = "png", dpi = 300); dev.off()

