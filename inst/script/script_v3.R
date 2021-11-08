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
                       EndYear=2020){

}

#Symbols="SPY"
#Symbols="BTC-USD"
#Symbols="ETH-USD"

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
  grDevices::dev.off()
  return(meassage("Finished!!"))
}else{
  grDevices::dev.off()
}

#Create DF
Dat00 <- data.frame(Date=index(Dat), Dat[,c(4)], row.names=seq_len(nrow(Dat)))
#head(Dat00)

#年、週目などの情報取得
Dat00$Year <- substring(Dat00$Date, start=1, stop=4)
Dat00$Week <- strftime(Dat00$Date, format = "%V")
Dat00$Year.Week <- paste0(Dat00$Year, Dat00$Week)
Dat00$Julian <- as.numeric(strftime(Dat00$Date, format = "%j"))
Dat00$Day <- sub("-", "", substring(Dat00$Date, 6, 10))
#head(Dat00); tail(Dat00); str(Dat00)

#372 (31*12) days
Days <- c()
for(n in 1:12){
Days <- c(Days, paste0(formatC(n, width=2, flag = "0"), formatC(seq(1, 31, 1), width=2, flag = "0")))
}

Dat01 <- data.frame(Date=Days)
Years <- paste0("Y", seq(Date00[1], Date00[2], 1))
Dat01[,Years] <- NA
#head(Dat01)

#Organize data
for(m in 1:length(Years)){
  #m <- 1
  a <- Dat00[Dat00$Year == sub("Y", "", Years[m]),]
  Dat01[c(Dat01$Date %in% a$Day),m+1] <- a$Close
}
#head(Dat01)



#それぞれの年初日を「0%」とする
Dat02 <- Dat01
for(m in 1:length(Years)){
b <- Dat02[,m+1]
Dat02[,m+1] <- Dat02[,m+1]/b[!is.na(b)][1]*100 - 100
}
head(Dat02)
#  Date     Y1994     Y1995      Y1996     Y1997      Y1998    Y1999
#1 0101        NA        NA         NA        NA         NA       NA
#2 0102        NA        NA  0.0000000 0.0000000  0.0000000       NA
#3 0103 0.0000000 0.0000000  0.2765904 1.4352047         NA       NA
#4 0104 0.4034970 0.4778157 -0.6789037        NA         NA 0.000000
#5 0105 0.6052455 0.4778157 -0.8800603        NA  0.2242152 1.143002
#6 0106 0.6052455 0.5802048         NA 0.5487547 -1.3773222 3.581407

#株価データが無い日を削除して、株価データを繋げる
Dat03 <- data.frame(Date=1:nrow(Dat01))
Dat03[,Years] <- NA
for(m in 1:length(Years)){
d <- Dat02[,m+1][!is.na(Dat02[,m+1])]
Dat03[,m+1] <- c(d, rep(NA, nrow(Dat01)-length(d)))
}

#株価データが無い(欠損数２以上)行を削除する
Dat03$MissingNum <- sapply(data.frame(t(Dat03[,-1])), function(x) sum(is.na(x)))
Dat03 <- Dat03[c(Dat03$MissingNum < 2),]

Dat04 <- Dat03
colnames(Dat04)
# [1] "Date"       "Y1994"      "Y1995"      "Y1996"      "Y1997"      "Y1998"      "Y1999"      "Y2000"
# [9] "Y2001"      "Y2002"      "Y2003"      "Y2004"      "Y2005"      "Y2006"      "Y2007"      "Y2008"
#[17] "Y2009"      "Y2010"      "Y2011"      "Y2012"      "Y2013"      "Y2014"      "Y2015"      "Y2016"
#[25] "Y2017"      "Y2018"      "Y2019"      "Y2020"      "Y2021"      "MissingNum"
dim(Dat04)
#[1] 248  30

#図 1. 2021年 Dat のSeasonality
Main <- "図 1. 2021年 Dat のSeasonality"
Y <- c(29)
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
quartz.save(file = paste0("./Dat_01.png"), type = "png", dpi = 300); dev.off()

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

#図 3. 2010-2020年 Dat のSeasonality
Main <- "図 3. 2010-2020年 Dat のSeasonality"
Y <- c(18:28)
#head(Dat04[,c(Y)])
Dat04$Mean <- NA
Dat04$Mean <- apply(data.frame(Dat04[,c(Y)]), 1, function(x) mean(x[!is.na(x)]))

COL <- "red1"
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
quartz.save(file = paste0("./Dat_03.png"), type = "png", dpi = 300); dev.off()

#図 4. 大統領選翌年 DatのSeasonality
#'97 '01 '05 '09 '13 '17
Main <- "図 4. 大統領選翌年 DatのSeasonality"
Y <- c(5, 9, 13, 17, 21, 25)
head(Dat04[,c(Y)])
#      Y1997     Y2001     Y2005      Y2009       Y2013     Y2017
#1 0.0000000 0.0000000  0.000000  0.0000000  0.00000000 0.0000000
#2 1.4352047 4.8034934 -1.221946 -0.1183315 -0.22593592 0.5949196
#3 0.5487547 3.6754003 -1.903575  0.5486252  0.21223949 0.5150013

Dat04$Mean <- NA
Dat04$Mean <- apply(data.frame(Dat04[,c(Y)]), 1, function(x) mean(x[!is.na(x)]))
colnames(Dat04)

COL <- "green1"
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
quartz.save(file = paste0("./Dat_04.png"), type = "png", dpi = 300); dev.off()
