#Shiny uygulamasının canlıya yüklenmesi
library(rsconnect)

rsconnect::setAccountInfo(name = '3weejq-halil0g0rkem-herek',
                          token = '3E5702C349223AE81DF8797B9CBD06E3',
                          secret = 'hm1JCL0LdKf/+7Tz85ygMftpM3u0qjlokgJNcAYQ')
rsconnect::deployApp(appName = 'DataSalaries',
                     appFiles = c("app.R", "Salaries-Report.html", "salaries.csv", "Salaries-Report.Rmd"),
                     account = '3weejq-halil0g0rkem-herek')

install.packages("usethis", repos = "https://cran.rstudio.com")
library(usethis)
use_git_config(user.name="halilgorkem", use.email="halilherek@gmail.com")
