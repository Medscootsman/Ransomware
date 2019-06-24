data <- read.csv("data/loocipher_malware.csv")

dataframe <- as.data.frame(data)

Sourceips <- as.data.frame(dataframe$Source)

protocols <- as.data.frame(dataframe$Protocol)

tableips <- table(Sourceips)

Sourceip_freq <- as.data.frame(table(Sourceips))

as.data.frame(table(protocols))
