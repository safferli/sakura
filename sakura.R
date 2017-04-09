options(bitmapType='cairo')
options(scipen = 999)

library(readxl)
library(dplyr)
library(ggplot2)
library(scales)
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

# sakura pink: #F9E9EC
# cherry blossom pink: #FFB7C5
# emojiOne sakura pink: #FF506E
# emojiOne light pink: #FFF0F3

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
  geom_smooth(method = "loess", span = 0.1, fill = "#FFB7C5", colour = "red")+
  theme_classic()


# plot as sakuras
dta %>% 
  # include the sakura as emoji character in dataset
  mutate(
    sakura.emoji = emoji("cherry_blossom"),
    # join to a common year for axis label (2000 is a leap year)
    common.date = as.Date(paste0("2000-", format(blossom.date, "%m-%d")), "%Y-%m-%d")
  ) %>%
  # plot in ggplot
  ggplot(aes(x=AD, y=common.date))+
  # alternatively, with geom_emoji:
  # geom_emoji("cherry_blossom", x=dta$AD, y=dta$Full.flowering.date..DOY., size = 3)+
  #geom_point(size = 0.5, colour = "red")+
  # include emoji as text, h-/vjust to center; strange it needs vjust 0.25 -- why? 975572 BD77A4
  geom_text(aes(label = sakura.emoji, hjust = 0.5, vjust = 0.25), family = "EmojiOne", size = 4, colour = "#FF506E")+
  # trend line
  geom_smooth(method = "loess", span = 0.1, fill = "#D2A5C2", colour = "grey", size = 0.5)+
  scale_y_date(
    name = "Date of cherry-blossom peak-bloom",
    breaks = c("2000-03-27", "2000-04-01", "2000-04-10", "2000-04-20", "2000-05-01", "2000-05-04") %>% as.Date(),
    # Apr-01
    labels = scales::date_format("%b-%d")
  )+
  scale_x_continuous(
    limits = c(800, 2020),
    # axis ticks every 200 years
    breaks = seq(800, 2000, 100),
    # no minor axis ticks in ggplot2::theme(): http://stackoverflow.com/questions/14490071/adding-minor-tick-marks-to-the-x-axis-in-ggplot2-with-no-labels
    # length(breaks): 13; replace every even element with empty string, to remove from axis labels
    labels = replace(seq(800, 2000, 100), seq(2, 12, 2), ""),
    name = "Year"
  )+
  labs(
    title = "Cherry Bomb", 
    subtitle = "Date of cherry-blossom peak-bloom in Kyoto, Japan, 800AD - 2016"
  )+
  # let's get close to the original graph's theme: 
  theme_classic()+
  theme(
    axis.line = element_line(colour = "black"),
    axis.ticks.x = element_line(colour = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(color = 'grey'),
    panel.background = element_blank()
  ) 







