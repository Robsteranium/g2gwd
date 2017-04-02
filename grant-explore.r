#===========================
# Load, inspect, and clean data
#===========================

# Set the working directory
setwd("/home/rueb/code/odm/repo")

# Read the Grant Nav csv data
gn <- read.csv("grantnav-10ksample.csv") # load the csv into a data frame (spreadsheet)
#gn.full <- read.csv("grantnav-20170325131809.csv")

# You can search the help pages with
?str  # for known functions
??xls # to search for functions


# Review the structure
View(gn) # a spreadsheet view
str(gn)  # view the structure (fields and types)
# each row is a grant award

# Cast the string to a date type
gn$Award.Date <- as.Date(as.character(gn$Award.Date))

# We could do other data-cleaning tasks, but this should suffice for now
# As an extension we might extract out the other tables (recipient location, beneficiary location)


#===========================
# Analysis with data.table
#===========================
install.packages("data.table")
library(data.table) # load up data.table library
setDT(gn) # convert the "data frame" to a "data table"
# https://s3.amazonaws.com/assets.datacamp.com/img/blog/data+table+cheat+sheet.pdf

gn # only shows the top and tail

# Let's extract some data from the table

#=== DT[extract-rows] ===
1:5     # gives a sequence of 1,2,3,4,5
gn[1:5] # extract first 5 rows

#=== DT[extract-rows, extract-columns] ===
gn[, .(Title, Amount.Awarded)]    # extract 2 columns by name
gn[1:5, .(Title, Amount.Awarded)] # extract rows by id, columns by name

# with index numbers in a different order
order(-gn$Amount.Awarded) # returns, for each row, the rank in descending order of amount
gn[order(-Amount.Awarded), .(Title,Amount.Awarded)]         # rank order of award by amount
gn[order(-Amount.Awarded), .(Title,Amount.Awarded)][1:10]   # top 10 biggest awards

# with boolean conditions
gn$Award.Date>strftime("2017-01-01") # returns, for each row, true if the date was this year
gn[Award.Date>strftime("2017-01-01"), .(Title,Award.Date)]  # extract awards made this year
gn[Funding.Org.Name=="BBC Children in Need"] # extract awards made by a given funder


#=== DT[extract-rows, calculate-summary] ===
gn[,.N] # count awards with the .N function
gn[Award.Date>strftime("2017-01-01"),.N] # count this years awards
gn[,.(total=sum(Amount.Awarded))] # use the sum function, assign the result into a "total" column

#=== DT[extract-rows, calculate-summary, group-by] ===
gn[,.N,.(Recipient.Region)]       # Number of awards by region
gn[,.(total=sum(Amount.Awarded)),.(Recipient.Region)] # Total award value by region


# Find and extract a column of recipient organisation names
# Which recipient org received the biggest single award?
# Which recipient org received the most awards (by number)?
# Which funding org awarded the most money?
# How many awards were made last year? (hint, there's a year function)


#===========================
# Visualisation with ggplot2
#===========================
install.packages("ggplot2")
library(ggplot2)

# An implementation of the grammar of graphics (a language for describing visualisations)
# aesthetic mapping: get from your data (Award.Amount) to something ggplot understand (x axis)
# geoms: visual features used to encode the data (e.g. bar, line or point chart)
# http://docs.ggplot2.org/current/
# https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf
# e.g. ggplot(data, aes(x,y)) + geom_point

#=== Basics of ggplot ===
df <- data.frame(a=10,b=12) # basic example data frame: 1 row, 2 columns
ggplot(df, aes(x=a, y=b)) + geom_point() # map variable a to the x axis, b to y, and render a point 

runif(10) # 10 random numbers (uniformly distributed between 0 and 1) 
df <- data.frame(a=runif(50), b=runif(50), c=1:5)
ggplot(df, aes(a, b, colour=c)) + geom_point() # encode c with colour
# didn't need to specify x and y when they're in the default position 

ggplot(gn, aes(Recipient.Region)) + geom_bar() # Count awards per Region
ggplot(gn, aes(Recipient.Region)) + geom_bar() + coord_flip() # Flip to make labels legible (can also zoom)


#=== What's the trend of amount awarded over time? ===
ggplot(gn, aes(Award.Date, Amount.Awarded)) + geom_point() # can't see the smaller awards and bigger ones at the same time
ggplot(gn, aes(Award.Date, Amount.Awarded)) + geom_point() + scale_y_log10() # change to scale to see both at once
ggplot(gn, aes(Award.Date, Amount.Awarded)) + geom_point(alpha=0.25) + scale_y_log10() # use transparency to avoid overplotting


# Group by month, aggregate with mean and standard error. A strange dip becomes apparent...
gn$Amount.Awarded.Month <- as.Date(cut(gn$Award.Date, breaks = "month"))
ggplot(gn, aes(Amount.Awarded.Month, Amount.Awarded)) + stat_summary() + scale_y_log10()

# Group by month and colour by funder. Too many colours to see what's going on...
ggplot(gn, aes(Amount.Awarded.Month, Amount.Awarded)) + stat_summary(aes(colour=Funding.Org.Name)) + scale_y_log10()

# Extract only the top few funders to simplify the chart
large_funders <- gn[,.(awards=.N),Funding.Org.Name][order(-awards)][1:8]$Funding.Org.Name
ggplot(gn[Funding.Org.Name %in% large_funders], aes(Amount.Awarded.Month, Amount.Awarded)) + stat_summary(aes(colour=Funding.Org.Name)) + scale_y_log10()



#=== How are award amounts distributed? ===

# Award values histogram, loads of small grants dwarf the few very large ones
ggplot(gn, aes(Amount.Awarded)) + geom_histogram()

# Log scale to see large and small at once
ggplot(gn, aes(Amount.Awarded)) + geom_histogram() + scale_y_log10()

# Cut out the very few, very big grants
ggplot(gn, aes(Amount.Awarded)) + geom_histogram() + scale_y_log10() + scale_x_continuous(limits=c(0,10^6))
# Don't forget this is a log scale

# Compute the cumulative distribution
library(scales)
gbp = dollar_format(prefix="£")
ggplot(gn[Funding.Org.Name %in% large_funders], aes(Amount.Awarded, colour=Funding.Org.Name)) +
  stat_ecdf() +
  scale_x_log10(name="Award Amount", labels=gbp, limits=c(500,10^6), breaks=c(500, 1000, 5000, 10000, 10^5, 10^6)) +
  scale_y_continuous(name="Proportion of Awards at this amount or lower", labels=percent) +
  theme_minimal() + theme(legend.position="bottom") +
  labs(colour="Funding Organisation", title="Distribution of Amounts Awarded by Funder")