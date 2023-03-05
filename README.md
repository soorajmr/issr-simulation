
# Feasibility Analysis of In-Situ Slum Redevelopment

This codebase accompanies the paper [In-situ Redevelopment of Slums in Indian Cities: Closing a Rent Gap?](https://www.tandfonline.com/doi/full/10.1080/02673037.2023.2180494)

**Citation:** 
>    Swastik Harish & Sooraj Raveendran (2023) In situ redevelopment of slums in Indian cities: Closing a rent gap?, Housing Studies, DOI: [10.1080/02673037.2023.2180494](https://www.tandfonline.com/doi/full/10.1080/02673037.2023.2180494)

A summary of the empirical analysis used in the paper is below.

## The Objective

The aim of the analysis was to check if state-facilitated in situ redevelopment of slums using private capital (abbreviated as ISSR) is a commercially viable model across different sizes and shapes of slums located all over urban India. 

### About ISSR

Slum redevelopment is an essential part of the Pradhan Mantri Awas Yojana—Urban (PMAY-U), India’s flagship national urban housing scheme. The In situ Redevelopment of Slums Using Land as a Resource component of the scheme is the only central government support available for housing interventions at the scale of the slum settlement. In other words, alternative intervention options like slum upgrading takes a backseat in the government's policy imagination. Land under slums is seen to have ‘market potential’ and by investing in it, the expectation is that area could be redeveloped and integrated into the ‘formal urban system’. A part of the land could be used to accommodate existing slum-dwellers, usually in mid- to high-rise apartment buildings. The remaining land may then be exploited commercially by allowing private development that could be sold at ‘market’ prices for high-income uses. If required, such deals could be ‘sweetened’ by relaxing planning regulations, incentives and direct subsidies. This is visually represented in the figure below. 

![image](https://user-images.githubusercontent.com/10476691/222949904-325b05e9-cf39-47d0-87a2-c8958b9fdfc7.png)
This figure shows the ISSR process: (a) An existing slum with its granular built form (b) The land is apportioned for redevelopment. Regulatory requirements of site setbacks constrain possible building footprints. (c) How the development usually takes the form of towers of redevelopment and premium housing.

## The Data Situation - Slum Characteristics

At the slum level, from multiple sources, we collected geospatial data containing the polygons of the slum land parcels and the number of households in each slum. This directly gives us the area of the slum land and density (number of households per unit area). Additionally we created a metric called Land Shape Index (LSI), defined as the ratio between the perimeter and the area of the land plot. This data was available for around 2700 slums in different cities. Apart from this, there were a good number of slums for which we had only partial informaiton - either the number of households or the spatial polygon was missing. We used a standard data imputation method to impute the data and finally had aa slum characteristics dataset containing 6139 slums. 

## Feasibility and Profitability

Once we had the slum characteristics data, we were in a position to ask the question we were interested in - "would ISSR be viable for each of these slums?" To get to the answer, though, we needed much more information. The figure below gives an idea of all the different pieces of information that go into calculating the project feasibility and profitability of the ISSR projects. 

![image](https://user-images.githubusercontent.com/10476691/222950712-744a60ad-1911-4c72-91d3-5d1799d68e7a.png)


## Other Data as Part of a Simulation

It is clear from the figure above that to arrive at feasibility and profitability numbers, apart fromm slum characteristics, we needed various factors (or indictors, variables) related to the local real estate market as well as the building regulations. It was not practically possible to gather this information at a site-level for each slum. Instead, we decided to define these at a city level, based on information collected form various reports and other sources. Rather than using definite values for these variables, we use a distribution - a range of possible values for each variable and the corresponding proportions / probabilities of these values in a given city. With these distibution, we ran a simulation analysis. The process of doing it is this: in the first step, we randomly pick any of the slum lands in our data set. Then, for all the real estate market and regulatory variables, from their respective probability distributions, we draw one value each. These together forms a hypothetical situation of a redevelopment project for the selected slums. As we repeat these steps tens of thousands of times, we consider multiple redevelopment scenarios for each slumn land parcel with slightly different values for the real estate and regulatory variables. 

## How do you make sense of the simulated data?

![image](https://user-images.githubusercontent.com/10476691/222952458-be3e44c9-55d3-4c0d-b8ba-e18a3acd7dfe.png)

![image](https://user-images.githubusercontent.com/10476691/222952485-bfc151bb-1b4e-449e-aef5-2f51a1a9b6c7.png)



## Implications and recommendations

