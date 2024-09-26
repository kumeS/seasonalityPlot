library(plumber)
library(seasonalityPlot)
library(ggplot2)


#path <- paste0(getwd(), "/", "plumber.R")
path <- paste0(getwd(), "/seasonality_API/", "plumber.R")
plumber::plumb(path)$run(host = "0.0.0.0", port = 7860)

#https://huggingface.co/spaces/skume/seasonalityPlot
#https://skume-seasonalityplot.hf.space
#https://skume-seasonalityplot.hf.space/plot
