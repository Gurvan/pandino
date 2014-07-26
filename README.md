#Pandino

Pandino is the result of an univesity project in statistics.

It is an **R** package aiming at ranking Twitter users from a local dataset based on their interests and their social characteristics. It is provided with a web interface and uses [openCPU](https://github.com/jeroenooms/opencpu) as an R backend.

##Getting started
First clone the [repository](https://github.com/Gurvan/pandino.git) or download and unzip the [archive](https://github.com/Gurvan/pandino/archive/master.zip).
In the file `getStarted.R` replace the line

```R
install('PUT THE PACKAGE DIRECTORY HERE') #example: install('~/R/pandino')
```
with the package directory, like in the example.

The you can execute the script `getStarted.R` to install the package, start the openCPU server and open the web insterface. It will install [devtools](http://cran.r-project.org/web/packages/devtools/index.html), [RCurl](http://cran.r-project.org/web/packages/RCurl/index.html) and [openCPU](http://cran.r-project.org/web/packages/opencpu/index.html) if you don't already have them.

##Structure
The **R** functions are located in `pandino.r`, in the `/R` folder. These functions manipulate the data from `pandino.rdata` located in the `/data` folder.

The code of the web interface is located in `/inst/www`. It is written in `HTML5 + CSS3 + JavaScript` with the use of `jQuery` and the `openCPU client` for JavaScript.