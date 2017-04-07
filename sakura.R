options(bitmapType='cairo')
options(scipen = 999)

library(readxl)
library(dplyr)
library(ggplot2)
# devtools::install_github("dill/emoGG")
library(emoGG)

# Define your workspace: "X:/xxx/"
wd <- "c:/github/sakura/"
setwd(wd)


# data is available on AONO's university homepage: 
# http://atmenv.envi.osakafu-u.ac.jp/aono/kyophenotemp4/
aono.dta <- "http://atmenv.envi.osakafu-u.ac.jp/osakafu-content/uploads/sites/251/2015/10/KyotoFullFlower7.xls"
# make sure to read as binary, because windows is stupid
download.file(aono.dta, "sakura.xls", mode= "wb")

dta <- readxl::read_excel("sakura.xls", skip = 25) %>% 
  # make "good" column names
  setNames(make.names(names(.), unique = TRUE)) %>% 
  # convert the blossom date to R dateformat 
  mutate(
    blossom.date = as.Date(paste0(sprintf("%04d", AD), "0", Full.flowering.date), format = "%Y%m%d")
  )

# emoji search knows no sakura... :( 
# emoGG::emoji_search("cherry")
# but it exists in unicode! 1f338
# http://emojipedia.org/cherry-blossom/


dta %>% 
  ggplot(aes(x=AD, y=Full.flowering.date..DOY.))+
  geom_emoji(emoji = "1f338")+
  # loess at span = 0.1 seems to match the model of The Economist
  # sakura pink = #F9E9EC; cherry blossom pink: #FFB7C5
  geom_smooth(method = "loess", span = 0.1, fill = "#FFB7C5")+
  theme_classic()



