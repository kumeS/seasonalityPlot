#Example of execution before CRAN submission (Mac / seasonalityPlot)
#Erase the variables NAMESPACE and man in the environment
#getwd();dir()
rm(list=ls())
system("rm -rf ./seasonalityPlot/NAMESPACE; rm -rf ./seasonalityPlot/man/*")

#roxygenise execution and display
roxygen2::roxygenise("./seasonalityPlot")
system("cat ./seasonalityPlot/NAMESPACE")

#Remove package and restart R
remove.packages("seasonalityPlot", lib=.libPaths())
.rs.restartR()

#Documentation
devtools::document("seasonalityPlot")
#reinstall
system("R CMD INSTALL seasonalityPlot")

#load
library(seasonalityPlot)
seasonPlot(Symbols = "^IXIC", useAdjusted = TRUE)
CryptoRSIheatmap(coin_num = 5, n = 21)

#dev check
devtools::check("seasonalityPlot", cran=TRUE)

#CRAN submit
devtools::submit_cran("./seasonalityPlot")

