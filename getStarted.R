if(!require(devtools)) install.packages('devtools')
library(devtools)

install('PUT THE PACKAGE DIRECTORY HERE') #example: install('~/R/pandino')

library(opencpu)
opencpu$start()
opencpu$browse('library/pandino/www')