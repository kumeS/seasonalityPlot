#年、週目などの情報取得
Dat00$Year <- substr(Dat00$Date, start=1, stop=4)
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
Dat03 <- Dat02[as.vector(apply(Dat02, 1, function(x) sum(is.na(x)))), ]
