# donutchart
Donut chart for R

Usage
--------

```r
library(tidyverse)
library(donutchart)

as_tibble(Titanic) %>% count(Class, wt=n) %>% rename(PassengersCount=nn) %>%
  donut_chart(Class, PassengersCount, "Class")
```

![alt text](DonutExample.svg "Example")

```r
library(tidyverse)
library(donutchart)

as_tibble(Titanic) %>% count(Class, wt=n) %>% rename(PassengersCount=nn) %>%
  donut_chart(Class, PassengersCount, includePercentage=F,
              "Class\nby Passenger Type", centerLabelSize=12, centerColor="black",
              startColor="#668391", endColor="#8C4A56")
```

![alt text](DonutExample2.svg "Example 2")