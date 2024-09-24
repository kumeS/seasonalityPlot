#' RSI Divergence Detection Function
#'
#' This function calculates the Relative Strength Index (RSI) and detects divergences between the RSI and price data. 
#' It identifies bullish and bearish divergences as well as pivot points. 
#' The results are visualized using `googleVis::gvisLineChart`.
#'
#' @param data An `xts` or `zoo` object containing the financial time series data. It must include the closing prices.
#' @param len Integer. The lookback period for calculating the RSI. Default is 14.
#' @param ob Numeric. The overbought threshold for RSI. Default is 70.
#' @param os Numeric. The oversold threshold for RSI. Default is 30.
#' @param omid Numeric. The midline value for RSI. Default is 50.
#' @param xbars Integer. The number of past bars (periods) to look back for divergence detection. Default is 90.
#' @param short_labels Logical. If `TRUE`, labels on the charts will be shortened. Currently not implemented. Default is `FALSE`.
#'
#' @importFrom quantmod
#' @importFrom googleVis 
#' @importFrom TTR
#' @importFrom magrittr 
#' 
#' @export RSIdivergencePlot
#' 
#' @return A list containing the following elements:
#' \item{plot_data}{A data frame with the calculated RSI values and identified divergences and pivots.}
#' \item{rsi_chart}{An interactive RSI chart object created by `googleVis::gvisLineChart`.}
#' \item{price_chart}{An interactive price chart object created by `googleVis::gvisLineChart`.}
#'
#' @examples
#' \dontrun{
#' 
#' result <- RSIdivergencePlot(Symbol="BTC-USD")
#' 
#' }
#' 


