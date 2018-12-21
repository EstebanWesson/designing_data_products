# Designing Data Products - H-1B Application Process

Combine and analyzed two public datasets to understand the H1-B process and its levers.

## Project

Every year there are 140K+ applications submitted with only an available pool of 85K. Employers and employees don't know if its possible to increase their chance of getting a visa. 

The process is allegedly random so this project tried to prove if this is true and if firms or individuals can perform specific actions to increase the probability of lottery approval.

## Methodology

To correctly analyze the H-1B process the first step was to clean the data. Extra information that includes the companies phone number and attorney name were deleted. After this, some feature engineering was necessary like changing some attributes to binary outcomes and normalize certain data. One of the most difficult tasks was combining the two datasets, which was made possible using the Jaro-Winkler distance from the "stringdist" package on the companies names. 

Once the data was ready two approaches were used, the first was a logistic regression and the second was a decision tree. 

## Conclusion

The model that gave the best outcome was the logistic regression which indicated that none of the attributes determine the likelihood of getting a visa. The null hypothesis that the visa process is random cannot be rejected because the p-values are not significant. 

## Resources

The datasets are too large to be included in this repository, they can be found in the following links:

* [Approved H-1B Petitions by Employer- 2017](https://www.uscis.gov/sites/default/files/USCIS/Data/Employment-based/H-1B/approved-h-1b-petitions-by-employer-fy-2017.csv)
* [H-1B Visa Applications - 2017](https://public.enigma.com/datasets/h-1-b-visa-applications-2017/e1ee0ae8-13f4-444f-804e-9a429b32f424?filter=%2B%5B%5D)
