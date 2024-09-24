library(hexSticker)

imgurl <- system.file("/inst/images/SeasonalityPlot_BTC-USD_StartYear2014_EndYear2020.png",
                      package="seasonalityPlot")
sticker(imgurl, package="seasonalityPlot", p_size=30, s_x=1, s_y=.78, s_width=.58,
        filename="./seasonalityPlot/inst/images/hexSticker_seasonalityPlot.png",
        dpi = 500)

