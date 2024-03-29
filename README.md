# [seasonalityPlot package](https://github.com/kumeS/seasonalityPlot)
 <img src="https://github.com/kumeS/seasonalityPlot/blob/main/inst/images/hexSticker_seasonalityPlot.png" align="right" height="139" />

[![CRAN](https://www.r-pkg.org/badges/version/seasonalityPlot)](https://CRAN.R-project.org/package=seasonalityPlot)
[![CRAN_latest_release_date](https://www.r-pkg.org/badges/last-release/seasonalityPlot)](https://cran.r-project.org/package=seasonalityPlot)
[![CRAN](https://cranlogs.r-pkg.org/badges/grand-total/seasonalityPlot)](https://www.datasciencemeta.com/rpackages)
[![CRAN downloads last month](http://cranlogs.r-pkg.org/badges/seasonalityPlot)](https://cran.r-project.org/package=seasonalityPlot)
[![CRAN downloads last week](http://cranlogs.r-pkg.org/badges/last-week/seasonalityPlot)](https://cran.r-project.org/package=seasonalityPlot)

R package for Creating Seasonality Plots of Stock Prices and Cryptocurrencies

[GitHub/seasonalityPlot](https://kumes.github.io/seasonalityPlot/)

# Version

1.2.1: Update seasonPlot & Add new function "CryptoRSIheatmap".

1.1.1: Update Figures.

1.1.0: CRAN 3rd version.

1.0.1: CRAN 2nd version.

0.99.3: CRAN version.

0.99.1: Newly Published the GitHub.

# Installation

### install from CRAN

```r
install.packages("seasonalityPlot", repos="http://cran.r-project.org")
```

### install the latest from GitHub

type the code below in the R console window

```r
install.packages("devtools", repos="http://cran.r-project.org")
library(devtools)
devtools::install_github("kumeS/seasonalityPlot")
```

or install from the source file with `sh` commands

```sh
git clone https://github.com/kumeS/seasonalityPlot.git
R CMD INSTALL seasonalityPlot
```

# Function

- seasonPlot: create seasonality plots for stock prices or cryptocurrencies

# Usage of seasonPlot function

```r
library(seasonalityPlot)

#Plot an averaging seasonality of SPDR S&P500 ETF (SPY) between 2012 and 2022.
seasonPlot(Symbols="SPY")

#useAdjusted = TRUE
seasonPlot(Symbols="SPY", useAdjusted = TRUE)
```

<div style="text-align: center">
  <img src="inst/images/SeasonalityPlot_SPY_StartYear2012_EndYear2022.png" width="750px">
</div>

```r
#Plot an averaging seasonality of Dow Jones Industrial Average (^DJI) between 2012 and 2022.
seasonPlot(Symbols="^DJI")
```

<div style="text-align: center">
  <img src="inst/images/SeasonalityPlot_^DJI_StartYear2012_EndYear2022.png" width="750px">
</div>

```r
#Plot an averaging seasonality of NASDAQ Composite (^IXIC) between 2012 and 2022.
seasonPlot(Symbols="^IXIC")
```

<div style="text-align: center">
  <img src="inst/images/SeasonalityPlot_^IXIC_StartYear2012_EndYear2022.png" width="750px">
</div>

```r
#Plot an averaging seasonality of Bitcoin (BTC-USD) between 2017 and 2022.
seasonPlot(Symbols="BTC-USD")
```

<div style="text-align: center">
  <img src="inst/images/SeasonalityPlot_BTC-USD_StartYear2017_EndYear2022.png" width="750px">
</div>

```r
#Plot an averaging seasonality of Ethereum (ETH-USD) between 2017 and 2022.
seasonPlot(Symbols="ETH-USD")
```

<div style="text-align: center">
  <img src="inst/images/SeasonalityPlot_ETH-USD_StartYear2017_EndYear2022.png" width="750px">
</div>

```r
#CryptoRSI Heatmap Function provides a heatmap visualization of RSI values for a specified number of cryptocurrencies.

CryptoRSIheatmap(coin_num = 200, useRank = 1000, n = 21, useRankPlot = TRUE, OutputData = FALSE)
```

<div style="text-align: center">
  <img src="inst/images/CryptoRSIheatmap.png" width="750px">
</div>

# License

Copyright (c) 2021 Satoshi Kume 

Released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

# Authors

- Satoshi Kume



