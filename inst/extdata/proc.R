#coin_Rank <- readRDS("./seasonalityPlot-main/inst/extdata/coin_Rank.Rds")
coin_Rank.df <- data.frame(coin_Rank)
head(coin_Rank.df)

coin_Rank.df.mc <- coin_Rank.df[order(-coin_Rank.df$market_cap),]
head(coin_Rank.df.mc)
row.names(coin_Rank.df.mc) <- 1:nrow(coin_Rank.df.mc)
#colnames(coin_Rank.df.mc)
coin_Rank.df.mc.v2 <- coin_Rank.df.mc[,c("id","slug","name","symbol","timestamp","ref_cur_id","ref_cur_name","close","volume","market_cap")]
head(coin_Rank.df.mc.v2)
saveRDS(coin_Rank.df.mc.v2, file="coin_Rank_v2.Rds")
