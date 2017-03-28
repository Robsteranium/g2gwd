# Getting to grips with data

ODM workshop on exploring and visualising data using examples from [GrantNav](http://grantnav.threesixtygiving.org/), a [360Giving](http://www.threesixtygiving.org/) application released under the terms of the [Creative Commons Attribution Sharealike License (CC-BY-SA)](https://creativecommons.org/licenses/by-sa/4.0/). See GrantNav's [copyright and attribution](http://grantnav.threesixtygiving.org/datasets/#copyright) list for details on the original data sources.

## Install R and RStudio

Install [R](https://cran.r-project.org/) and the [RStudio graphical user interface](https://www.rstudio.com/products/rstudio/download/) then start RStudio.

Windows users:

- [Download R for Windows](https://cran.r-project.org/bin/windows/base/R-3.3.3-win.exe)
- [Download RStudio for Windows](https://download1.rstudio.org/RStudio-1.0.136.exe)

Mac users:

- [Download R for Mavericks](https://cran.r-project.org/bin/macosx/R-3.3.3.pkg)
- [Download RStudio for OSX 10.6+](https://download1.rstudio.org/RStudio-1.0.136.dmg)

Linux users:

- [R binary packages](https://cran.r-project.org/bin/linux/) or search your package manager (e.g. `r-base` in ubuntu)
- [RStudio binaries](https://www.rstudio.com/products/rstudio/download/)

## Download the GrantNav data, and an R script

- Download the [GrantNav 10,000 award sample](grantnav-10ksample.csv) file and the [R script for the workshop](grant-explore.r). You can get both in a zip archive on the [releases page](https://github.com/Robsteranium/g2gwd/releases).
- Open the `grant-explore.r` script in RStudio
- You'll need to set the working directory (see the `setwd` command) to the folder where you downloaded the csv

