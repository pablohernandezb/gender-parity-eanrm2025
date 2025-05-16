## Gender Parity Analysis in Authoritarian Elections: Case Venezuela

This repository contains the code and data for my research project on ****candidate placement on the Venezuelan parliamentary and regional elections****.

**1. Introduction**

* **Research Question:** Under an authoritarian regime that still engages in elections, how parties and their leaders place their candidates based on gender? Given that they have a quota mandate that is not strongly enforced by the CNE (the electoral management body).
* **Objective:** This descriptive study aims to capture the party leaders behavior when placing candidates in districts and proportional representation lists to capture any potential bias based on gender.
* **Significance:** After making a transition into a fully authoritarian regime, is important to address women participation in these type of regimes, especially when there are quota mandates which is an institution typically used in democratic regimes.
* **Background:** In democracies, PR lists are institutions made to advance female candidates, but ultimately political party leaders place women in lower positions which makes them unliely to be elected due to the seats allocation and vote share. Moreover, Venezuela offers an unique case to assess the effect of single member districts with substitutes candidates for this electoral rule. This makes another potential source of bias against women since there are no placemente mandates and women are more likely to be placed as subtitutes instead of principals.

**2. Data**

* **Data Sources:**
    * The candidate dataset comes from the Consejo Nacional Electoral (CNE), which is the Venezuelan electoral management (https://doe.postulaciones.org.ve/eanr2025).
    * 2021 Regional and 2024 Presidential Elections results to assess whether party leaders place women in more difficult districts to win.

* **Data Description:**
    * This research aims to shed light on the party dynanmics when quotas are not enforced in an authoritarian setting, more specifically, for legislative elections of:
      * National Parliament: the Venezuela National Assembly
      * Sub-National Legislatures: State Legislative Councils
      * Sub-National Executives: Governorships
    * There are 6667 candidates, which include 3066 females (45.98%) and 3601 males (54.02%)

**3. Methodology**

* **Research Design:**
    * Following , I compare models based on the election rule (SMD and PR) and type (National Assembly and State Legislative Councils)
* **Software and Packages:**
    * To conduct this research I mainly used R version 4.4.3 (2025-02-28 ucrt) to conduct the statistcal models
    * Python v3.13 was employed to scrappe the data from the CNE's website

**4. Code**

* **Structure:** 
    * The repository contains the following scripts for scraping and data cleaning: 
        * `scrape.py` and `scrape_election_type_X.py`: Scrapes the data from the CNE
        * `json_to_csv.py`: Convert .json files to .csv to prepare them for data analysis on R
        * `genarete_csv_by_election.py`: Produce .csv by each of the seven election types for individual analysis
        * `collapse_data.py`: Collapse data by candidates to merge their supporting parties in one single field
        *  `append_csv.py`: Combine all .csv files obtained from the scraping process
        *  `circumscriptions_by_state.py`: Obtain the national and sub-national districts for the legilative elections depending on the geographic level by state

**5. Preliminary Results**

* **Key Findings:** 
    * Depending on election type, there is a varied level of bias againts women. Governor elections are the ones that has less female candidates, which makes sense since there are no quotas. More than 81.49% of the candidates are males. For the legislative elections, only state legislatures are the ones that reach gender parity, the rest have less than 50% of females candidates. 
* **Visualizations and Plots:** 
    * See the following plots for visualizations of preliminary findings, more results and robustsness checks can be seen on the plots and results directories: 
        * [Candidates' Gender by State](https://github.com/pablohernandezb/gender-parity-eanr2025/blob/main/plots/fig_cand_por_estado.png)
        * [Candidates' Gender by Election Type](https://github.com/pablohernandezb/gender-parity-eanr2025/blob/main/plots/fig_porct_gen_tipo_eleccion.png)
        * The rest of the plots from the preliminary analysis can be seen [here](https://github.com/pablohernandezb/gender-parity-eanr2025/tree/main/plots)

**6. Conclusion**

    * Comming soon.

**7. Acknowledgements & Contributing**

* Contributions to this project are welcome. You can contribute by:
    * Reporting bugs or issues
    * Suggesting improvements to the code
    * Contributing new features or analyses

**8. License**

* This code is released under the MIT License
