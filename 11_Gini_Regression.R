
library(dplyr)
library(sandwich)
library(lmtest)


data <- read.csv("/Users/sid/Library/CloudStorage/OneDrive-DeakinUniversity/UDocs - D/DataSets/ma2020/2020catdata_main.csv")
# Encode district as a factor (assuming 'district' is a categorical variable)
data$dist <- as.factor(data$District)
data$stat <- as.factor(data$State)

# Keep if alesina>0
data <- data[data$alesina > 0, ]
data <- data[data$num > 2, ]

# Assuming your data frame is named 'data'
model <- lm(alesina ~ med_per_1000 + edu_per_1000 + share_roads  
            + share_rails + share_pubtn + arg_per_1000 
            + adm_per_1000 + num + nearest_urban_proximity + area  
            + as.factor(dist)
            # + as.factor(stat)
            , data = data)

# Compute robust standard errors
#robust_se <- sqrt(diag(vcovHC(model, type = "HC1")))
robust_se <- coeftest(model, vcov = vcovHC(model, type="HC1"))

# Print coefficients and robust standard errors
#summary(model)
print(summary(model)$coefficients[0:11, , drop = FALSE])
#print(robust_se)
print(robust_se[1:11, ])

