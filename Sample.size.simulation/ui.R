#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(broom)
library(pwr)

# Define UI for application 
shinyUI(fluidPage(
    titlePanel("Sample Size Simulation and Calculator Tool"),
    sidebarLayout(
        sidebarPanel(
            actionButton("goButton", "Run experiment!"),  
            
            #Numeric Inputs
            numericInput("mu.val", "Enter starting mean", 100),
            numericInput("sd.val", "Enter starting standard deviation", 20),
            
            sliderInput(inputId = "sample.size",
                        label = "Choose a sample size",
                        min = 3,
                        max = 100,
                        value = 3,
                        step = 1,
                        animate =
                            animationOptions(interval = 300, loop = TRUE)),
            sliderInput(inputId = "replicate",
                        label = "Repititions",
                        min = 1,
                        max = 10,
                        value = 1,
                        step = 1,
                        animate =
                            animationOptions(interval = 500, loop = TRUE)),
            #display dynamic UI
            uiOutput("mu.slider"),
            uiOutput("sd.slider"),
            sliderInput(inputId = "diff.mu",
                        label = "% difference in treatment means to be detected",
                        min = 0,
                        max = 100,
                        value = 10),
            sliderInput(inputId = "alpha",
                        label = "Type I error (false positive) - Significance level (alpha)",
                        min = 0,
                        max = 1,
                        value = 0.05),
            sliderInput(inputId = "beta",
                        label = "Type II error (false negative) - Power (beta)",
                        min = 0,
                        max = 1,
                        value = 0.80),
            h4("Recommended sample size based on supplied inputs:"),
            h3(textOutput(outputId = "best.sample.size"))
            ),
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("How to use this tool", 
                                 h4(tags$b("Motivation for the tool:")),
                                 h5("The act of collecting data is often time consuming and expensive. 
                                    However, not collecting enough data can lead to decisions (some time 
                                    very important ones) based on false conclusions from sample data that
                                    did not accurately represent the entire population. This shiny app is
                                    intended to help demonstrate why sample size is important for good 
                                    statistical inference and how standard deviation, effect size and 
                                    significance level all influence sample size decisions."),
                                 
                                 h4(tags$b("To get started:")),
                                 h5("To the left you will see a series of input boxes and slider bars that will
                                    be manipulated to simluate different experimental conditions."),
                                 h5("1. Choose a starting mean"),
                                 h5("2. Choose a starting standard deviation"),
                                 h5("3. Choose a starting sample size"),
                                 h5("4. Choose the % difference between treatment means that you would like to detect. 
                                    Are you trying to detect a small or large difference between treatments?"),
                                 h5("5. Choose the desired significance level or alpha; the probability of falsely concluding a 
                                    difference in means when there is no difference (falsely rejecting the null 
                                    hypothesis)."),
                                 h5("6. Choose the desired power or beta; the probability of falsely concluding no difference 
                                    between means when there is a difference (falsely accepting the null hypothesis)."),
                                 
                                 h4(tags$b("Simulating experiments and plotting results:")),
                                 h5(tags$li("At the top left you see a button labeled", tags$b("Run experiment!"), ". This button will take 
                                    a random sample (using the sample size you have defined) from the populations A and B
                                    that you have defined. The result of this random sampling is then plotted in horizontal 
                                    boxplots seen on the", tags$b("Plots"), "tab. Each time you click this button a new random sample is taken.")),
                                 h5(tags$li("Alternatively you can use the Replicate slider bar to chose a new replicate. This 
                                    slider can also be animated by pressing the play button in the bottom righthand corner.
                                    The slider will loop until it is paused.")),
                                 h5(tags$li("After each random sampling a t-test is ran between treatments A and B and the
                                            resulting p-value is reported at the top of the plot. If the p-value is lower than 
                                            the choosen significance level then the p-vlaue is labeled", tags$b("Statistically significant"))),
                                 h5(tags$li("At the bottom of the left side panel you will see the recommended sample size based on currently
                                            selected conditions.")),
                                 
                                 h4(tags$b("Go and have fun:")),
                                 h5("Now adjust everything you can think of and observe the effect."),
                                 h5(tags$li("Observe what happens to estimated sample size with changes in each parameter?")),
                                 h5(tags$li("What happens to the p-value with changes in each parameter?")),
                                 h5(tags$li("Observe what happens to the position of the boxplots as experiments are repeated with increasing 
                                            sample sizes and or decreasing standard deviations.")),
                                 h5(tags$li("Finally, click the checkbox below the boxplots to see the true distributions of treatments A and B.
                                            This graph has the same x-axis as the boxplot. Compare the two plots to evaluate if the sample was a 
                                            good estimation of the population."))
                                 ),
                        tabPanel("Plots", 
                                 plotOutput("sample.box"),
                                 checkboxInput(inputId = "showplot",
                                               label = "Show the true distribution of treatment populations",
                                               value = FALSE),
                                 conditionalPanel(
                                     condition = "input.showplot",
                                     plotOutput("density")
                                     )
                                 )
                        )
            )
        )
)
)
    