#' Creates a donut chart.
#
#' @param data The data set.
#' @param groupColumn The column with the categorical labels.
#' @param totalsColumn The column with the categorical totals.
#' @param centerLabel The label displayed in the center of the donut.
#' @param centerColor The color of the donut's center.
#' @param centerLabelColor The font color of the donut's center label.
#' @param centerLabelSize The font size of the donut's center label.
#' @param startColor The starting color of the range of colors used for the slices.
#' @param endColor The ending color of the range of colors used for the slices.
#' @param outerLabelColor The font color of the outer labels.
#' @param outerLabelSize The font size of the outer labels.
#' @param includePercentage Whether to include percentages next to the slices.
#' @param nudgeouterLabels How far to nudge the outer labels away from the slices.
#' @return A donut chart (a ggplot object).
#' @examples
#' as_tibble(Titanic) %>% count(Class, wt=n) %>% rename(PassengersCount=nn) %>%
#'   donut_chart(Class, PassengersCount, "Class")
donut_chart <- function(data, groupColumn, totalsColumn, centerLabel = "",
                       centerColor="#767676", centerLabelColor="white", centerLabelSize=4,
                       startColor="#00c896", endColor="#678fdc",
                       outerLabelColor="black", outerLabelSize=2.5,
                       includePercentage=T, nudgeouterLabels=0)
    {
    overallTotal = sum(eval(substitute(totalsColumn), data))

    totalsColumn <- enquo(totalsColumn)
    groupColumn <- enquo(groupColumn)

    innerAreaData = data %>% summarize(totals=sum(!!totalsColumn))

    graphData = data %>% rename(grouping=!!groupColumn) %>% group_by(grouping) %>%
        summarize(totals=sum(!!totalsColumn)) %>%
        arrange(desc(totals)) %>%
        mutate(csum=cumsum(totals), pos=csum-totals/2) %>% group_by(1:n())

    sliceLabels <- c()
    if (includePercentage)
        { sliceLabels <- sprintf("%s\n(%s%%)", graphData$grouping,
                                          comma(round((graphData$totals/overallTotal)*100))) }
    else
        { sliceLabels <- graphData$grouping }

    ggplot() +
        #inner label
        geom_bar(data=innerAreaData, aes(x=1, y=totals), fill=centerColor, stat="identity", width=1) +
        geom_text(data=innerAreaData, aes(x=.5, y=overallTotal/2, label=centerLabel),
                  color=centerLabelColor, size=centerLabelSize) +

        #outer slices
        geom_bar(data=graphData,
                 aes(x=2, y=totals, fill=totals),
                 color="white", position="stack", stat="identity") +

        #labels for each slice
        geom_text_repel(data=graphData,
                        aes(label=sliceLabels,
                            x=2.75, y=pos),
                        nudge_x=nudgeouterLabels,
                        segment.alpha=0,
                        size=outerLabelSize, color=outerLabelColor,
                        point.padding = NA, direction = "y") +

        scale_fill_continuous(low=startColor, high=endColor, guide=F) +
        #turn off the content around the chart
        theme(axis.title.y=element_blank(),
              axis.text.y=element_blank(),
              axis.ticks.y=element_blank(),
              axis.text.x=element_blank(),
              axis.ticks.x=element_blank(),
              axis.title=element_blank(),
              axis.line.x=element_blank(),
              axis.line.y=element_blank(),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank(),
              panel.background = element_blank()
              ) +
        coord_polar('y')
    }
