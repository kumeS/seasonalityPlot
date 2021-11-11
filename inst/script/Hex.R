library(hexSticker)

sticker(~plot(cars, cex=.5, cex.axis=.5, mgp=c(0,.3,0), xlab="", ylab=""),
        package="seasonalityPlot",
        p_size=20, s_x=.8, s_y=.6, s_width=1.4, s_height=1.2,
        filename="./seasonalityPlot/inst/images/hexSticker_seasonalityPlot.png")

imgurl <- system.file("/inst/images/SeasonalityPlot_BTC-USD_StartYear2014_EndYear2020.png",
                      package="seasonalityPlot")
sticker(imgurl, package="seasonalityPlot", p_size=30, s_x=1, s_y=.78, s_width=.58,
        filename="./seasonalityPlot/inst/images/hexSticker_seasonalityPlot.png",
        dpi = 500)

