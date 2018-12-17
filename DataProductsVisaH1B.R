library(readr)
library(stringdist)
library(dplyr)

########################################
#H1-B Visa Requests 2017
visa2017 <- read_csv("Visa2017.csv")

#Remove all of this columns because they aren't relevant to what we need
visa2017$employer_address <- NULL
visa2017$employer_phone <- NULL
visa2017$employer_phone_ext <- NULL
visa2017$naics_code <- NULL
visa2017$employer_business_dba <- NULL
visa2017$employer_state <- NULL
visa2017$employer_province <- NULL
visa2017$employer_city <- NULL
visa2017$employer_postal_code <- NULL
visa2017$wage_rate_of_pay_to <- NULL
visa2017$worksite_county <- NULL
visa2017$agent_attorney_name <- NULL
visa2017$agent_attorney_city <- NULL
visa2017$agent_attorney_state <- NULL
visa2017$public_disclosure_location <- NULL
visa2017$worksite_postal_code <- NULL
visa2017$pw_source_other <- NULL
visa2017$pw_source <- NULL
visa2017$pw_source_year <- NULL
visa2017$worksite_postal_code <- NULL
visa2017$labor_con_agree <- NULL
visa2017$pw_wage_level <- NULL
visa2017$new_employment <- NULL
visa2017$worksite_city <- NULL
visa2017$continued_employment <- NULL
visa2017$change_previous_employment <- NULL
visa2017$new_concurrent_employment <- NULL
visa2017$support_h1b <- NULL
visa2017$total_workers <- NULL


#Deletes all the rows where the employer withdrew the visas
visa2017 <- visa2017[!(visa2017$case_status == "WITHDRAWN"),]

#Creates new column "visastatus" and changes CERTIFIED and CERTIFIED-WITHDRAWN to "1" and DENIED to "0"
#From "case_status" column
visa2017$visastatus <- visa2017$case_status
visa2017$visastatus <- gsub('CERTIFIED', 1, visa2017$visastatus)
visa2017$visastatus <- gsub('-WITHDRAWN', '', visa2017$visastatus)
visa2017$visastatus <- gsub('DENIED', 0, visa2017$visastatus)

#Creates new colum "attorney" and changes "Y" to 1, "N" to 0 and NA to 1
#From "agent_representing_employer"
visa2017$attorney <- visa2017$agent_representing_employer
visa2017$attorney <- gsub('Y', 1, visa2017$attorney)
visa2017$attorney <- gsub('N', 0, visa2017$attorney)
visa2017$attorney[is.na(visa2017$attorney)] <- 1

#Creates new column "full_time" and changes "Y" to 1, "N" to 0 and eliminates NA rows
visa2017$full_time <- visa2017$full_time_position
visa2017$full_time <- gsub('Y', 1, visa2017$full_time)
visa2017$full_time <- gsub('N', 0, visa2017$full_time)
visa2017 <- visa2017[!(is.na(visa2017$full_time) | visa2017$full_time==""), ]

#Creates new column "visaViolator" and changes "Y" to 1, "N" to 0 and eliminates NA rows
visa2017$visaViolator <- visa2017$willful_violator
visa2017$visaViolator <- gsub('Y', 1, visa2017$visaViolator)
visa2017$visaViolator <- gsub('N', 0, visa2017$visaViolator)
visa2017 <- visa2017[!(is.na(visa2017$visaViolator) | visa2017$visaViolator==""), ]

#Creates new column "visaDependant" and changes "Y" to 1, "N"
visa2017$visaDependant <- visa2017$h1b_dependent
visa2017$visaDependant <- gsub('Y', 1, visa2017$visaDependant)
visa2017$visaDependant <- gsub('N', 0, visa2017$visaDependant)

#Delete all rows that have 0 for the "prevailing_wage"
visa2017<-visa2017[!(visa2017$prevailing_wage=="0"),]

#Deletes all the rows where the "pw_unit_of_pay" is NA, only 4 rows
visa2017 <- visa2017[!(is.na(visa2017$pw_unit_of_pay) | visa2017$pw_unit_of_pay==""), ]

#Change all the amounts in "prevailing_wage" to a yearly rate
#This means Hour*40*52, Month*12, Week*12, Bi-Weekly*26
#Use this function to see all the unique values in the column unique(visa2017$pw_unit_of_pay)
visa2017$pw_yearly <- visa2017$prevailing_wage
visa2017 <- transform(visa2017, pw_yearly=ifelse(pw_unit_of_pay=='Hour', prevailing_wage*2080, 
                                                 ifelse(pw_unit_of_pay=='Month', prevailing_wage*12, 
                                                        ifelse(pw_unit_of_pay=='Week', prevailing_wage*52, 
                                                               ifelse(pw_unit_of_pay=='Bi-Weekly', prevailing_wage*26, prevailing_wage)))))

#Delete an outlier with error on yearly prevailing wage
visa2017<-visa2017[!(visa2017$case_number=="I-200-17079-327361"),]

#Deletes all the rows where the "wage_unit_of_pay" is NA, only 2 rows
visa2017 <- visa2017[!(is.na(visa2017$wage_unit_of_pay) | visa2017$wage_unit_of_pay==""), ]

#Change all the amounts in "wage_rate_of_pay_from" to a yearly rate
#This means Hour*40*52, Month*12, Week*12, Bi-Weekly*26
#Use this function to see all the unique values in the column unique(visa2017$wage_unit_of_pay)
visa2017$actual_yearly_rate <- visa2017$wage_rate_of_pay_from
visa2017 <- transform(visa2017, actual_yearly_rate=ifelse(wage_unit_of_pay=='Hour', wage_rate_of_pay_from*2080, 
                                                 ifelse(wage_unit_of_pay=='Month', wage_rate_of_pay_from*12, 
                                                        ifelse(wage_unit_of_pay=='Week', wage_rate_of_pay_from*52, 
                                                               ifelse(wage_unit_of_pay=='Bi-Weekly', wage_rate_of_pay_from*26, wage_rate_of_pay_from)))))

#Drop values that are above the 98% percentile for both "pw_yearly" and "actual_yearly_rate" 
visa2017 <- visa2017[visa2017$pw_yearly < quantile(visa2017$pw_yearly, 0.98), ]
visa2017 <- visa2017[visa2017$actual_yearly_rate < quantile(visa2017$actual_yearly_rate, 0.98), ]

#Drop values that are below the 2% percentile for "actual_yearly_rate" 
visa2017 <- visa2017[visa2017$actual_yearly_rate > quantile(visa2017$actual_yearly_rate, 0.02), ]
visa2017 <- visa2017[visa2017$actual_yearly_rate > quantile(visa2017$actual_yearly_rate, 0.02), ]

#Delete visas with special treaties "E-3 Australian", "H-1B1 Singapore" and "H-1B1 Chile"
visa2017<-visa2017[!(visa2017$visa_class=="E-3 Australian"),]
visa2017<-visa2017[!(visa2017$visa_class=="H-1B1 Singapore"),]
visa2017<-visa2017[!(visa2017$visa_class=="H-1B1 Chile"),]


########################################
#Approved Visa by Employeer Calculations
#Data was clean before hand removing the first three 
approved2017 <- read_csv("Approved2017Employers.csv")

#Remove all of this columns because they aren't relevant to what we need
approved2017$employer_tax_number <- NULL
approved2017$degree <- NULL
approved2017$approved_per_degree <- NULL

#Remove all the the rows with empty values in the first column because we are not using the distribution by degree
approved2017 <- approved2017[!(is.na(approved2017$employer_name) | approved2017$employer_name==""), ]

#Remove rows that have 0 or "TOTAL" as employer
approved2017 <- approved2017[!(approved2017$employer_name == 0),]
approved2017 <- approved2017[!(approved2017$employer_name == "TOTAL"),]

#Change the Value from "D" for an average of 5 assuming that there is a normal distribution around the range of 0<x<10
approved2017$total_number_approved[is.na(approved2017$total_number_approved)] <- 5


##########################################
#Fuzzy matching name of companies using Jaro-Winker distance 
for (i in length(visa2017$employer_name)){
  nameDist <- stringdistmatrix(i, approved2017$employer_name, method="jw")
  visa2017$nameLabel[visa2017$employer_name==i] <- which.min(nameDist)
}
visa2017$approvedName <- approved2017$employer_name[visa2017$nameLabel]


#Frequency of submitted visas by company
submitted2017 <- as.data.frame(table(visa2017$approvedName))
names(submitted2017)[1]  = 'employer_name'

#Insert into "submitted2017" average anual salary of the submitted visas 
submitted2017$averageSalarySubmitted <- sapply(split(visa2017$actual_yearly_rate, visa2017$approvedName), mean)

#Insert into "submitted2017" if the company is H1-B dependant
visa2017$visaDependant <- as.numeric(as.character(visa2017$visaDependant))
submitted2017$h1bdependant <- sapply(split(visa2017$visaDependant, visa2017$approvedName), mean)

#Insert into "submitted2017" if the company is a Willfull violator
visa2017$visaViolator <- as.numeric(as.character(visa2017$visaViolator))
submitted2017$visaViolator <- sapply(split(visa2017$visaViolator, visa2017$approvedName), mean)

#Insert into "submitted2017" if the company tends to use an attorney or agent
visa2017$attorney <- as.numeric(as.character(visa2017$attorney))
submitted2017$attorney <- sapply(split(visa2017$attorney, visa2017$approvedName), mean)

#Insert into "submitted2017" the approved visas
dplr <- left_join(submitted2017, approved2017, by=c("employer_name"))

########################################
#Linear regression - not used
VisaREG <- lm(log(total_number_approved)~log(Freq)+log(averageSalarySubmitted)+log(h1bdependant)+log(visaViolator)+log(attorney)+log(average_salary), data=dplr)

#P-Values
summary(VisaREG)$coefficients[,4]

#Logistic Regression 
VisaGLM <- glm(total_number_approved~Freq+averageSalarySubmitted+h1bdependant+visaViolator+attorney+average_salary,family=gaussian(link="log"),data=dplr)

#P-Values
summary(VisaGLM)$coefficients[,4]

########################################
#Output files
visa2017file  <- dplr[,c("employer_name", "Freq", "averageSalarySubmitted", "h1bdependant", "visaViolator", "attorney", "total_number_approved", "average_salary")]
write.csv(visa2017file, file = "visa2017file.csv")


