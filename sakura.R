options(bitmapType='cairo')
options(scipen = 999)

library(readxl)
library(dplyr)
library(ggplot2)
# deprecated: devtools::install_github("dill/emoGG")
library(emojifont)

# Define your workspace: "X:/xxx/"
wd <- "c:/github/sakura/"
setwd(wd)

# download data if not already on disk
if(!file.exists("sakura.xls")){
  # data is available on AONO's university homepage: 
  # http://atmenv.envi.osakafu-u.ac.jp/aono/kyophenotemp4/
  aono.dta <- "http://atmenv.envi.osakafu-u.ac.jp/osakafu-content/uploads/sites/251/2015/10/KyotoFullFlower7.xls"
  # make sure to read as binary, because windows is stupid
  download.file(aono.dta, "sakura.xls", mode= "wb")
} 

# read in data
dta <- readxl::read_excel("sakura.xls", skip = 25) %>% 
  # make "good" column names
  setNames(make.names(names(.), unique = TRUE)) %>% 
  mutate(
    # convert the blossom date to R dateformat 
    blossom.date = as.Date(paste0(sprintf("%04d", AD), "0", Full.flowering.date), format = "%Y%m%d")
  )

# emoji search knows no sakura... :( 
# emoGG::emoji_search("cherry")
# but it exists in unicode! 1f338
# http://emojipedia.org/cherry-blossom/

# need this to load the font
load.emojifont()
# only needed for RStudio
windows()


# plot with sakura background
dta %>% 
  ggplot(aes(x=AD, y=Full.flowering.date..DOY.))+
  #geom_emoji(emoji = "1f338")+
  geom_emoji("cherry_blossom", x=1408, y=104.5)+
    # "cherry_blossom",
    # x = mean(dta$Full.flowering.date..DOY.), # 1408
    # y = mean(dta$Full.flowering.date..DOY., na.rm = TRUE) # 104.5
    # )+
  #geom_point()+
  # loess at span = 0.1 seems to match the model of The Economist
  # sakura pink = #F9E9EC; cherry blossom pink: #FFB7C5
  geom_smooth(method = "loess", span = 0.1, fill = "#FFB7C5", colour = "red")+
  theme_classic()


# plot as sakuras
dta %>% 
  # include the sakura as emoji character in dataset
  mutate(
    sakura.emoji = emoji("cherry_blossom")
  ) %>%
  # plot in ggplot
  ggplot(aes(x=AD, y=Full.flowering.date..DOY.))+
  #geom_emoji("cherry_blossom", x=1408, y=104.5)+
  geom_point(size = 2, colour = "red")+
  # include emoji as text, h-/vjust to center; strange it needs vjust 0.25 -- why? 
  geom_text(aes(label = sakura.emoji, hjust = 0.5, vjust = 0.25), family="EmojiOne", size = 4)+
  geom_smooth(method = "loess", span = 0.1, fill = "#FFB7C5", colour = "red")+
  theme_classic()







