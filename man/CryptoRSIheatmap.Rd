% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CryptoRSIheatmap.R
\name{CryptoRSIheatmap}
\alias{CryptoRSIheatmap}
\title{CryptoRSI Heatmap Function}
\usage{
CryptoRSIheatmap(
  coin_num = 200,
  useRank = 1000,
  n = 21,
  minDataPoints = NULL,
  useRankPlot = TRUE,
  OutputData = FALSE
)
}
\arguments{
\item{coin_num}{An integer specifying the number of coins to display in the 
heatmap. Must be less than the value of `useRank`.}

\item{useRank}{An integer defining the range within which coins are randomly 
selected based on their market cap ranking. Defaults to 1000.}

\item{n}{An integer indicating the number of periods for calculating moving 
averages in the RSI computation. Defaults to 21.}

\item{minDataPoints}{An integer specifying the minimum number of data points 
required for each coin. Defaults to `n + 5`.}

\item{useRankPlot}{A boolean that determines if the x-axis should plot ranks 
instead of sequential numbers. Defaults to TRUE.}

\item{OutputData}{A boolean that decides if the function should return the 
final plot data table or only display the heatmap plot. Defaults to FALSE.}
}
\value{
If `OutputData` is TRUE, returns a data frame with symbols, ranks (or sequential numbers), RSI values, and colors for plotting. Otherwise, displays a heatmap plot.
}
\description{
This function generates a heatmap of RSI values for a randomly 
   selected subset of cryptocurrencies. The coins are chosen based on their market 
   cap ranking, and the function provides insights into market sentiment using RSI. 
   It allows for visualizing potential overbought or oversold conditions.
}
\details{
CryptoRSI Heatmap Function

Generates a heatmap of the Relative Strength Index (RSI) for a randomly selected
subset of cryptocurrencies. This function uses the `crypto2` and `TTR` packages
to fetch cryptocurrency data and calculate RSI values, respectively. The heatmap
visualizes RSI values to identify potential overbought or oversold conditions in
the crypto market.
}
\examples{
\dontrun{

# A heatmap of 200 coins using 21 days RSI
CryptoRSIheatmap(coin_num = 200, n = 21)

# A heatmap of 300 coins using 90 days RSI
CryptoRSIheatmap(coin_num = 300, n = 90)
}
}
\author{
Satoshi Kume
}
