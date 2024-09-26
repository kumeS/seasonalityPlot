library(plumber)
library(seasonalityPlot)
library(ggplot2)

# Title
#* @apiTitle seasonalityPlot API

# Description
#* @apiDescription This API allows users to access the functionalities of the `seasonalityPlot` R package via a web interface. It provides tools to generate seasonality plots for stock prices and cryptocurrencies, as well as visualizations such as the CryptoRSI heatmap, which displays RSI values across multiple cryptocurrencies. This API enables users to perform these operations without installing the package locally, making the analysis of financial trends and market behaviors accessible from any environment.


# Contact object
#* @apiContact list(name = "Satoshi Kume", url = "https://kumes.github.io/skume-Biography/skume-Biography.html", email = "satoshi.kume.1984@gmail.com")
# License object
#* @apiLicense list(name = "Artistic License 2.0", url = "http://www.perlfoundation.org/artistic_license_2_0")
# TOS link
#* @apiTOS 
# Version
#* @apiVersion 1.2.1
# Tag Description
#* @apiTag seasonalityPlot "API" "generating seasonality plots" "CryptoRSI heatmaps" "`seasonalityPlot`"


# CORSを有効にするためのフィルター
#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*") # 任意のオリジンからのアクセスを許可
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS") # 許可するメソッド
  res$setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization") # 許可するヘッダー
  
  # Preflightリクエストに対する応答
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }else{
      plumber::forward() # 次の処理に進む
  }
}


# Define the Plumber API endpoint
#* Root Endpoint
#* @get /
#* @serializer contentType list(type="image/png")
function() {
  
  # Create a temporary file for the PNG output
  temp_file <- tempfile(fileext = ".png")
  
  # Explicitly open a PNG device to save the plot
  png(temp_file, width = 500, height = 500)
  
  # Call the seasonPlot function to generate the plot
  seasonPlot(Symbols = "BTC-USD", StartYear=2015, EndYear=2020)
  
  # Close the PNG device after the plot is created
  dev.off()
  
  # Read the PNG file into a binary object
  img <- readBin(temp_file, "raw", n = file.info(temp_file)$size)
  
  # Return the PNG image
  return(img)
}

#* Create a scatter plot
#* @param Symbol a string of Symbol
#* @param StartYear a numeric vector of Start Year
#* @param EndYear a numeric vector of End Year
#* @get /seasonPlot_symbol
#* @serializer contentType list(type="image/png")
function(Symbol = "ETH-USD",
         StartYear = 2015, 
         EndYear = 2020) {

  # Create a temporary file for the PNG output
  temp_file <- tempfile(fileext = ".png")
  
  # Explicitly open a PNG device to save the plot
  png(temp_file, width = 500, height = 500)
  
  # Call the seasonPlot function to generate the plot
  seasonPlot(Symbols = Symbol, 
             StartYear=as.numeric(StartYear), 
             EndYear=as.numeric(EndYear))
  
  # Close the PNG device after the plot is created
  dev.off()
  
  # Read the PNG file into a binary object
  img <- readBin(temp_file, "raw", n = file.info(temp_file)$size)
  
  # Return the PNG image
  return(img)

}



#* Create a scatter plot
#* @param x a numeric vector of x values
#* @param y a numeric vector of y values
#* @get /plot_test
#* @serializer contentType list(type="image/png")
function(x, y) {
  library(ggplot2)
  
  # Convert input to numeric vectors
  x_vals <- as.numeric(unlist(strsplit(x, ",")))
  y_vals <- as.numeric(unlist(strsplit(y, ",")))
  
  # Create a data frame
  df <- data.frame(x = x_vals, y = y_vals)
  
  # Generate a plot
  p <- ggplot(df, aes(x = x, y = y)) +
    geom_point() +
    theme_minimal()
  
  # Create a temporary file for the PNG output
  temp_file <- tempfile(fileext = ".png")
  
  # Explicitly open a PNG device to save the plot
  png(temp_file, width = 500, height = 500)
  
  # Output the plot to the PNG device
  print(p)
  
  # Close the PNG device after the plot is created
  dev.off()
  
  # Check if the file exists and its size is greater than 0 before proceeding
  if (file.exists(temp_file) && file.info(temp_file)$size > 0) {
    # Read the PNG file into a binary object
    img <- readBin(temp_file, "raw", n = file.info(temp_file)$size)
    
    # Return the PNG image
    return(img)
  } else {
    stop("Failed to create the PNG file.")
  }
}

