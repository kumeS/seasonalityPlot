##' @title seasonPlot: create seasonality plots for stock prices or cryptocurrencies
##'
##' @description This function is to easily create a seasonality plot with some color options.
##' This can use the same symbols as the quantmod package (e.g. SPY, BTC-USD, and ETH-USD etc).
##' For the average calculation, the trading days for each month are aligned and then
##' the percentages of change with the beginning of the year being zero are calculated.
##' This function can set any given time period for averaging.
##' In addition, years with many missing data are automatically excluded before the calculation.
##'
##' @param Symbols a character vector specifying the names of each symbol to be loaded.
##' e.g. ^IXIC (NASDAQ Composite), ^DJI (Dow Jones Industrial Average), SPY (SPDR S&P500 ETF), BTC-USD (Bitcoin), and ETH-USD (Ethereum).
##' @param StartYear a numeric of start year (Common Er)
##' @param EndYear a numeric of end year (Common Er)
##' @param LineColor a numeric; The value 1 is to select red1,
##' the value 2 is to select blue1, the value 3 is to select green1,
##' and the value 4 is to select black.
##' When BackgroundMode is TRUE, this argument is disabled.
##'
##' @param xlab a character of X-axis label.
##' @param BackgroundMode a logical; draw a background color by react.
##' @param alpha a numeric; The alpha parameter is a number between 0.0 (fully transparent) and 1.0 (fully opaque).
##' @param Save a logical; save as an image (PNG) or not
##' @param output_width a output size of width (pixel). Initial value recommended.
##' @param output_height a output size of height (pixel). Initial value recommended.
##' @param OutputData a logical; output as a data.frame type or not.
##' @param family a character of font.
##' @param PlotAll a logical; display all period by dygraph function or not.
##'
##' @return plot results
##' @author Satoshi Kume
##'
##' @import quantmod
##' @import magrittr
##' @import plotrix
##' @import dygraphs
##' @import htmltools
##' @import grDevices
##' @import graphics
##' @importFrom utils askYesNo
##' @importFrom zoo index
##' @importFrom magrittr %>%
##'
##' @export seasonPlot
##'
##' @examples \donttest{
##'
##' ## Search by SPY (S&P500 index)
##' seasonPlot(Symbols = "SPY")
##'
##' }
##'

seasonPlot <- function(Symbols,
                       StartYear=2010,
                       EndYear=2020,
                       LineColor=1,
                       xlab="Month",
                       BackgroundMode=TRUE,
                       alpha=0.05,
                       OutputData=FALSE,
                       Save=FALSE,
                       output_width=1000,
                       output_height=700,
                       family="Helvetica",
                       PlotAll=FALSE){

oldpar <- graphics::par(no.readonly = TRUE)
on.exit(graphics::par(oldpar))

if(!is.numeric(StartYear)){return(message("Warning: No poper value of StartYear"))}
if(!is.numeric(EndYear)){return(message("Warning: No poper value of EndYear"))}
error <- try(quantmod::getSymbols(Symbols, auto.assign=TRUE), silent=T)
if(class(error) == "try-error"){return(message("Warning: No poper value of Symbols"))}
if((StartYear - EndYear) >= 0){
  if((StartYear - EndYear) == 0){return(message("Warning: StartYear and EndYear are the same value"))}
  return(message("Warning: No poper value of StartYear or EndYear"))
}

Date <- c(paste0(StartYear, "-01-01"), paste0(EndYear, "-12-31"))
Dat <- quantmod::getSymbols(Symbols, src = "yahoo", verbose = T, auto.assign=FALSE, from = Date[1], to=Date[2])
colnames(Dat) <- c("Open", "High", "Low", "Close", "Volume", "Adjusted")
#head(Dat); str(Dat)
Date00 <- range(as.numeric(substr(zoo::index(Dat), start=1, stop = 4)))
if((Date00[1] - Date00[2]) >= 0){return(message("Warning: No poper value of StartYear or EndYear"))}

#Plot All
if(PlotAll){
Dat[,4] %>%
  dygraphs::dygraph(main = paste0(Symbols, " Close Price: ",  Date00[2]-Date00[1], "-years")) %>%
  dygraphs::dySeries("Close", label = "Dat") %>%
  dygraphs::dyRangeSelector(height = 40)
YN <- utils::askYesNo("Do you want to proceed to the next step?")
if(!YN){
  return(message("Finished!!"))
}}

#Create DF
Dat00 <- data.frame(Date=zoo::index(Dat), Dat[,c(4)], row.names=seq_len(nrow(Dat)))
#head(Dat00)

#Organize data
Dat00$Year <- substr(Dat00$Date, start=1, stop=4)
Dat00$Month <- substr(Dat00$Date, start=6, stop=7)
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
for(m in 2:ncol(Dat01)){
  #m <- 2
  a <- Dat00[Dat00$Year == sub("Y", "", colnames(Dat01)[m]),]
  Dat01[c(Dat01$Date %in% a$Day),m] <- a$Close
}
#head(Dat01); tail(Dat01)
#more that 366/2 days
Dat02 <- Dat01[, as.vector(apply(Dat01, 2, function(x) sum(is.na(x))) < 366/2)]
Dat03 <- Dat02
Dat02$Month <- substr(Dat02$Date, start=1, stop=2)
Mon <- unique(Dat02$Month)
#head(Dat02)

for(k in Mon){
#k <- "01"
Dat02a <- Dat02[Dat02$Month == k,]
#head(Dat02a)
for(m in 2:ncol(Dat03)){
#m <- 6
a <- Dat02a[,m]
#head(a)
SUM <- sum(is.na(a))
if(SUM == 0){
  Dat03[c(Dat02$Month == k), m] <- a
}else{
  b <- a[!is.na(a)]
  b <- c(b, rep(NA, SUM))
  Dat03[c(Dat02$Month == k), m] <- b
}}}
#head(Dat03); tail(Dat03)
Dat04 <- Dat03[as.vector(apply(Dat03, 1, function(x) sum(is.na(x)))) < diff(Date00)*0.6, ]
#head(Dat04); tail(Dat04)

#Set the first day of the year as "0%".
for(m in 2:ncol(Dat04)){
#m <- 2
d <- Dat04[,m]
Dat04[,m] <- (d/d[!is.na(d)][1])*100 - 100
}
Dat04$Month <- substr(Dat04$Date, start=1, stop=2)
#head(Dat04)
MonTable <- table(Dat04$Month)

#Delete the days with no data and connect the data
Dat04$MissingNum <- sapply(data.frame(t(Dat04[,-c(1,ncol(Dat04))])), function(x) sum(is.na(x)))
#table(Dat04$MissingNum)
Dat04 <- Dat04[c(Dat04$MissingNum < diff(Date00)*0.2),]
Dat05 <- Dat04
#table(is.na(Dat05))

#Plot
Main <- paste0(Symbols, " Seasonality: ", Date00[1], "-", Date00[2])
Dat05$Mean <- NA
Dat05$Mean <- apply(data.frame(Dat05[,c(2:(ncol(Dat05)-3))]), 1, function(x) mean(x[!is.na(x)]))
#head(Dat05)

switch(as.character(LineColor),
       "1" = COL <- "red1",
       "2" = COL <- "blue1",
       "3" = COL <- "green1",
       "4" = COL <- "black",
       COL <- "black")
St <- Dat05$Mean; St00 <- St[!is.na(St)]

PLOT <- function(St=St, St00=St00, Dat05=Dat05, xlab=xlab,
                 BackgroundMode=BackgroundMode, alpha=alpha, Symbols=Symbols,
                 family=family){
graphics::par(family=family, lwd=1, xpd=F, cex=1, mgp=c(0.5, 1, 0), mai=c(0.5, 0.75, 0.5, 0.5))
plot(St, type="n", axes = F,
     xlab=xlab,
     ylab="", cex.lab=0.75, xlim=c(0,nrow(Dat05)),
     ylim=c(min(St00) - (max(St00)- min(St00))*0.1, max(St00) + (max(St00)- min(St00))*0.15),
     xaxs="i", yaxs="i", main=Main, cex.lab=1.2)

A <- round(range(St), 0)
A1 <- diff(A)/20; A <- A + c(-A1, A1)
if(A[1] < 0){A[1] <- floor(A[1]/10)*10}else{A[1] <- ceiling(A[1]/10)*10}
if(A[2] < 0){A[2] <- floor(A[2]/10)*10}else{A[2] <- ceiling(A[2]/10)*10}
A[1] <- signif(A[1], digits = nchar(as.character(abs(A[1])))-1)
A[2] <- signif(A[2], digits = nchar(as.character(abs(A[2])))-1)
B <- signif(diff(A), digits = 2)
C <- cumsum(as.numeric(table(Dat05$Month)))

if(BackgroundMode){
D <- c(0, C)
G <- NULL
for(n in 1:12){
#head(Dat05)
#n <- 2
E <- Dat05$Mean[Dat05$Month == names(MonTable)[n]]
E1 <- E[!is.na(E)]
E2 <- E1[length(E1)] - E1[1]

if(E2 < 0){
rect(D[n]+2, A[1],
     D[n+1]-2, A[2], col=grDevices::rgb(1,0,0, alpha=alpha),
     border=NA)
G <- c(G, "red1")
}else{
rect(D[n]+2, A[1],
     D[n+1]-2, A[2], col=grDevices::rgb(0,1,0, alpha=alpha),
     border=NA)
G <- c(G, "green1")
}}}

axis(side=2,
     labels=paste0(seq(A[1], A[2], by=B/10), "%"),
     at=seq(A[1], A[2], by=B/10), las=2)
Lin <- seq(A[1], A[2], by=B/10)
for(l in 1:12){
  lines(c(C[l], C[l]),
      c(Lin[1], Lin[11]), col="grey", lty=3, lwd=0.75)
}
abline(h=seq(A[1], A[2], by=B/10), col="black", lty=1, lwd=0.25)

plotrix::boxed.labels(C-c(as.numeric(table(Dat05$Month))/2),
                      min(St00) - (max(St00)- min(St00))*0.075,
                      month.abb, cex=0.9, bg = "grey20", xpad = 1.2, ypad = 1.2)

if(BackgroundMode){
D <- c(1, C)
for(n in 1:12){
lines(D[n]:D[n+1], St[D[n]:D[n+1]], col=G[n], lwd=1.2)
}
}else{
  lines(St, col=COL, lwd=1.2)
  legend("topleft", legend=Symbols, col=COL, lwd=1, cex=1)
}
}

if(Save){
grDevices::png(filename = paste0("SeasonalityPlot_", sub(" ", "_", Symbols),
                  "_StartYear", Date00[1], "_EndYear", Date00[2], ".png"),
    width=output_width, height=output_height, res=150)
PLOT(St=St, St00=St00, Dat05=Dat05, xlab=xlab, BackgroundMode=BackgroundMode, alpha=alpha, Symbols=Symbols, family=family)
grDevices::dev.off()
PLOT(St=St, St00=St00, Dat05=Dat05, xlab=xlab, BackgroundMode=BackgroundMode, alpha=alpha, Symbols=Symbols, family=family)
}else{
PLOT(St=St, St00=St00, Dat05=Dat05, xlab=xlab, BackgroundMode=BackgroundMode, alpha=alpha, Symbols=Symbols, family=family)
}

if(OutputData){
  #head(Dat05)
  return(list(Symbols=Symbols,
              MeanData=Dat05))
}
}
