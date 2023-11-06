# Appendix 3.2 RStudio code for data visualization
# By Grace Seo
#	Contains detailed code for various data transformation and plotting


###=================================================###
### Load libraries
###=================================================###
library(here) # instead of setwd
library(tidyverse) # data transformation
library(ggplot2) # plotting
library(ggpubr) # ggarrange - multiple plot in one view
library(grid)   # for the textGrob() function
library(splitstackshape) # for variant column split

library(ggbreak) # scale_y_break or scale_x_break
library(ggforce) # facet_zoom() to zoom in specific region of the graph
library(svglite) # ggsave in svg format - final plot


###=================================================###
### Functions for data visualization # Ct values
###=================================================###
fxn_rt_ggplot <- function(data, x, y, lab_x, lab_y, lab_colour, y_min, y_max, y_inc, legend_colourscheme) {
    ggplot(data, aes({{x}}, # qpcr_ct
                     {{y}}, # genome_completeness
                     colour = Reverse_transcriptase,
                     group = Reverse_transcriptase)) + ## change
        geom_point(size = 10) + #position = position_jitter(w = 0.5, h = 0, seed = 1)) + 
        geom_line(size = 2) + #position = position_jitter(w = 0.5, h = 0, seed = 1)) +
        #facet_wrap(~Reverse_transcriptase) + ## change
        xlab(lab_x) +
        ylab(lab_y) + 
        labs(colour = lab_colour) + 
        #scale_x_continuous(limits = c(x_min, x_max), breaks = seq(x_min, x_max, by = x_inc)) + 
        scale_y_continuous(limits = c(y_min, y_max), breaks = seq(y_min, y_max, by = y_inc)) +
        theme(panel.background = element_rect(fill = NA),
              panel.border = element_rect(linetype = "solid", colour = "black", fill = NA, size = 1), # plot borderline
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(), 
              #legend.position = "none",
              legend.title = element_text(size = 30),
              legend.text = element_text(size = 25),
              legend.key.size = unit(1, 'cm'),
              axis.title = element_text(size = 30),
              axis.text.x = element_text(size = 25, angle = 0, hjust = 0.5, vjust = 0.5),
              axis.text.y = element_text(size = 25, angle = 0, hjust = 1.0, vjust = 0.5),
              strip.text = element_text(size = 30)) +
        scale_colour_manual(values = legend_colourscheme)
}


fxn_rt_sample_ggplot <- function(data, x, y, lab_x, lab_y, lab_colour, y_min, y_max, y_inc, legend_colourscheme) {
    ggplot(data, aes({{x}}, # qpcr_ct
                     {{y}}, # genome_completeness
                     colour = sample,
                     group = sample)) + ## change
        geom_point(size = 10) + #position = position_jitter(w = 0.5, h = 0, seed = 1)) + 
        geom_line(size = 2) + #position = position_jitter(w = 0.5, h = 0, seed = 1)) +
        #facet_wrap(~Reverse_transcriptase) + ## change
        xlab(lab_x) +
        ylab(lab_y) + 
        labs(colour = lab_colour) + 
        #scale_x_continuous(limits = c(x_min, x_max), breaks = seq(x_min, x_max, by = x_inc)) + 
        scale_y_continuous(limits = c(y_min, y_max), breaks = seq(y_min, y_max, by = y_inc)) +
        theme(panel.background = element_rect(fill = NA),
              panel.border = element_rect(linetype = "solid", colour = "black", fill = NA, size = 1), # plot borderline
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(), 
              #legend.position = "none",
              legend.title = element_text(size = 30),
              legend.text = element_text(size = 25),
              legend.key.size = unit(1, 'cm'),
              axis.title = element_text(size = 30),
              axis.text.x = element_text(size = 25, angle = 0, hjust = 0.5, vjust = 0.5),
              axis.text.y = element_text(size = 25, angle = 0, hjust = 1.0, vjust = 0.5),
              strip.text = element_text(size = 30)) +
        scale_colour_manual(values = legend_colourscheme)
}



###=================================================###
### Functions for plotting sample cases
###=================================================###

### COVID-19 cases per month 
fxn_allcases_bar_ggplot <- function(data, x, y, lab_x, lab_y, lab_colour, y_min, y_max, y_inc, set_colour) {
    ggplot(data, aes({{x}}, # date monthly
                     {{y}}, # 
                     fill = prname)) +
                     #colour = sample_name)) + ## change
        geom_bar(stat = "identity", position = "stack", width = 6) + # position = position_dodge(preserve = 'single'), #- preserve box size despite missing data +
        #facet_wrap(~Reverse_transcriptase) + ## change
        xlab(lab_x) +
        ylab(lab_y) + 
        labs(fill = lab_colour) + 
        #scale_y_break(c(scaleBreak_min, scaleBreak_max), space = spacing) + ## space add space between breakpoints
        scale_x_date(labels = date_format("%B %Y"), breaks = "3 months") +
        #scale_y_continuous(n.breaks = num_of_breaks) +
        scale_y_continuous(limits = c(y_min, y_max), breaks = seq(y_min, y_max, by = y_inc)) +
        theme(panel.background = element_rect(fill = NA),
              panel.border = element_rect(linetype = "solid", colour = "black", fill = NA, size = 1), # plot borderline
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(), 
              #legend.position = "none",
              legend.title = element_text(size = 15),
              legend.text = element_text(size = 10),
              legend.key.size = unit(0.5, 'cm'),
              axis.title = element_text(size = 15),
              axis.text.x = element_text(size = 10, angle = 90, hjust = 0.95, vjust = 0.2),
              axis.text.y = element_text(size = 10, angle = 0, hjust = 1.0, vjust = 0.5),
              strip.text = element_text(size = 15)) +
        scale_fill_manual(values = set_colour)
}


### COVID-19 variant cases per month 
fxn_vocCases_bar_ggplot <- function(data, x, y, lab_x, lab_y, lab_colour, y_min, y_max, y_inc, set_colour) {
    ggplot(data, aes({{x}}, # date monthly
                     {{y}}, # 
                     fill = Identifier)) +
                     #colour = sample_name)) + ## change
        geom_bar(stat = "identity", position = "stack", width = 6) + # position = position_dodge(preserve = 'single'), #- preserve box size despite missing data +
        #facet_wrap(~Reverse_transcriptase) + ## change
        xlab(lab_x) +
        ylab(lab_y) + 
        labs(fill = lab_colour) + 
        #scale_y_break(c(scaleBreak_min, scaleBreak_max), space = spacing) + ## space add space between breakpoints
        scale_x_date(labels = date_format("%B %Y"), breaks = "3 months") +
        #scale_y_continuous(n.breaks = num_of_breaks) +
        scale_y_continuous(limits = c(y_min, y_max), breaks = seq(y_min, y_max, by = y_inc)) +
        theme(panel.background = element_rect(fill = NA),
              panel.border = element_rect(linetype = "solid", colour = "black", fill = NA, size = 1), # plot borderline
              panel.grid.major = element_blank(), 
              panel.grid.minor = element_blank(), 
              #legend.position = "none",
              legend.title = element_text(size = 15),
              legend.text = element_text(size = 10),
              legend.key.size = unit(0.5, 'cm'),
              axis.title = element_text(size = 15),
              axis.text.x = element_text(size = 10, angle = 90, hjust = 0.95, vjust = 0.2),
              axis.text.y = element_text(size = 10, angle = 0, hjust = 1.0, vjust = 0.5),
              strip.text = element_text(size = 15)) +
        scale_fill_manual(values = set_colour)
}



### In Excel, convert "date" column into "2020-01-01" Date format then save.

### Load dataset and filter data by column values
data_voc <- read.csv(here("data/20220814_covid19-epiSummary-variants.csv"), header = TRUE)

data_voc <- as.data.frame(data_voc)

### convert date into numeric "Date" type
data_voc$Collection_week <- as.Date(data_voc$Collection_week)
class(data_voc$Collection_week)
#View(data_voc)
head(data_voc)

### Create a new column divided by monthly
data_voc <- data_voc %>% mutate(Month = as.Date(cut(Collection_week, start = "2020-01-01",
                                                    breaks = "month", 
                                                    start.on.monday = FALSE)))
#View(data_voc)

### remove Canada from the list - using all provinces result in double dipping
data_voc_monthly <- data_voc %>% select(Month, Identifier, X.CT.Count.of.Sample..) 
#View(data_voc_monthly)

data_voc_monthly <- data_voc_monthly %>% group_by(Month, Identifier) %>% summarise(n = sum(X.CT.Count.of.Sample..))


### aggregate all numbers - not needed if want to colour by province
#data_voc_monthly <- aggregate(cbind(n)~Month, data = data_voc_monthly, FUN = sum)

#write.csv(data_voc_monthly, here("output/intro_Canada_covid_voc_cases.csv"))

### Create a new column divided by weekly
data_voc <- data_voc %>% mutate(Week = as.Date(cut(Collection_week, start = "2020-01-01",
                                                   breaks = "week", 
                                                   start.on.monday = FALSE)))
#View(data_voc)



### remove Canada from the list - using all provinces result in double dipping


data_voc_weekly <- data_voc %>% select(Week, Identifier, X.CT.Count.of.Sample..) 
#View(data_voc_weekly)

data_voc_weekly <- data_voc_weekly %>% group_by(Week, Identifier) %>% summarise(n = sum(X.CT.Count.of.Sample..))

#View(data_voc_weekly)

### aggregate all numbers - not needed if want to colour by province
#data_voc_weekly <- aggregate(cbind(n)~Week, data = data_voc_weekly, FUN = sum)

#View(data_voc_weekly)


#write.csv(data_voc_weekly, here("output/intro_Canada_covid_VOC_cases_weekly.csv"))



