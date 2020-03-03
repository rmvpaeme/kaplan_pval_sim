require(survival)
require(survminer)
require(dplyr)

load(file = "KM.Rdata")

number_participants <- 300
FUtime <- 96

patientID <- c(1:number_participants) # Participant labels

sex    <- rbinom(number_participants, 1, 0.5)
sex    <- factor(sex,
                 levels = c(0, 1),
                 labels = c("Male", "Female"))

P      <- 3                    # number of groups
X      <- rlnorm(number_participants, 4, 1)      # continuous covariate

IV     <- factor(sample(c("Low", "Medium", "High"), number_participants, replace = TRUE))  # factor covariate

scenario   <- rbinom(number_participants, 1, 0.3)
scenario   <- factor(scenario,
                     levels = c(0, 1),
                     labels = c("A", "B"))
scenarioEff <- c(0, -2)

IVeff  <- c(0, -1, 1.5)        # effects of factor levels (1 -> reference level)
Xbeta  <-  0.7 * log10(X) + IVeff[unclass(IV)] + rnorm(number_participants, 0 , 2) + scenarioEff[unclass(scenario)]

weibA  <- 1.5 # Weibull shape parameter
weibB  <- 100 # Weibull scale parameter
U      <- runif(number_participants, 0, 1) # uniformly distributed RV
followup <- ceiling((-log(U) * weibB * exp(-Xbeta)) ^ (1 / weibA)) # simulated event time
#eventtype <- rbinom_rep(input$SampleSizeA, 1, abs(1-input$CensoringA))  # Event: censored or not?
eventtype <- rep(1, number_participants)
toy_dataset <- data.frame(patientID, followup, eventtype, scenario, sex, X, IV)   # Make dataframe
colnames(toy_dataset) <- c(
  "PatientID",
  "Followup",
  "Eventtype",
  "Treatment",
  "Sex",
  "GeneExpression",
  "IncomeBinned"
) 

toy_dataset$Eventtype[toy_dataset$Followup >= FUtime] <- 0 

for (level in factor(toy_dataset$GeneExpression)){
  if (level > 2){
      toy_dataset$dichot <- ifelse(as.numeric(toy_dataset$GeneExpression) > as.numeric(level), "above cutoff", "below cutoff")
      fit <- survfit(Surv(time = Followup , event = Eventtype) ~ dichot, data = toy_dataset)
      
      p1 <- ggsurvplot(
        fit,
        title = paste0("The gene count cutoff is set at: ", round(as.numeric(level), 0)),
        data = toy_dataset,
        pval = TRUE,
        pval.method = FALSE,
        conf.int = FALSE,
        xlim = c(0, 0.90 * (FUtime)),
        break.time.by = round(FUtime / 6, 0),
        pval.coord = c(.50, 0.10),
        tables.y.text = FALSE, risk.table = "nrisk_cumcensor",
        risk.table.fontsize = 4 ,risk.table.height = 0.20)
      
      p1
      
      if (!is.null(as.numeric(gsub("[^0-9.-]", "", p1[["plot"]][["layers"]][[4]][["aes_params"]][["label"]])))){
      
        pval = round(as.numeric(gsub("[^0-9.-]", "", p1[["plot"]][["layers"]][[4]][["aes_params"]][["label"]])),2)
        
        ggsave(paste0("./",round(as.numeric(level), 0),"_cutoff_", pval, ".png"), plot = print(p1, newpage = FALSE), dpi = 300)}
        }
}
