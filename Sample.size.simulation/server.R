#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


library(shiny)

# Define server logic 
shinyServer(function(input, output) {
    
    output$mu.slider <- renderUI({
        sliderInput("slider.out.mu", "Mean", min=input$mu.val * 0.5, max=input$mu.val * 1.5, value = input$mu.val)
    })
    output$sd.slider <- renderUI({
        sliderInput("slider.out.sd", "Standard Deviation", min=input$sd.val * 0.5,  max=input$sd.val * 1.5, value = input$sd.val)
    })
    
    #create a function for alpha to be used in other places
    alpha <- reactive({
        input$alpha
    })
    
    output$density <- renderPlot({
        data.pop <- tibble(treatment = c(rep("A", times = 10000),
                                         rep("B", times = 10000)
        ),                                                                          
        property = c(rnorm(n = 10000,
                           mean = input$slider.out.mu,
                           sd = input$slider.out.sd),
                     rnorm(n = 10000,
                           mean = input$slider.out.mu + input$slider.out.mu * input$diff.mu/100,
                           sd = input$slider.out.sd)
                     )
        )
        
        ggplot(data = data.pop,
               aes(x = property,
                   fill = treatment)
        ) + 
            geom_density(alpha = 0.5)+
            theme(text = element_text(size = 16))+
            guides(fill = guide_legend(title = "Treatment"))+
            labs(x = "Property",
                 y = "Frequency",
                 title = "True Distribution of Treatment Populations",
                 subtitle = "Distribution of 10,000 Observations from Treatments A and B")+
            scale_x_continuous(limits = c(input$slider.out.mu - 3* (input$sd.val * 1.5),
                                          input$slider.out.mu * (1 + input$diff.mu / 100) + 3* (input$sd.val * 1.5)
                                          )
                               )
    })

    output$sample.box <- renderPlot({
        # Take a dependency on input$goButton. This will run once initially,
        # because the value changes from NULL to 0.
        input$goButton
        
        # create data
        data.sample <- tibble(treatment = c(rep("A", times = input$sample.size * 10),
                                            rep("B", times = input$sample.size * 10)
                                            ),
                                       replicate = c(rep(1:10, each = input$sample.size),
                                                     rep(1:10, each = input$sample.size)
                                                     ),
                                       property = c(rnorm(n = input$sample.size * 10,
                                                          mean = input$slider.out.mu,
                                                          sd = input$slider.out.sd),
                                                    rnorm(n = input$sample.size * 10,
                                                          mean = input$slider.out.mu + input$slider.out.mu * input$diff.mu/100,
                                                          sd = input$slider.out.sd)
                                                    )
                                       )
        
        # p.value from randomly sampled data                        
        p.value <- tidy(t.test(data.sample$property[data.sample$treatment == "A"],
                               data.sample$property[data.sample$treatment == "B"],
                               alternative = "two.sided",
                               paired = FALSE,
                               conf.level = alpha()))$p.value
        
        difference <- ifelse(p.value > input$alpha, "", "Statistically significant")
        
        
        #create graph
        ggplot(data = data.sample %>% 
                   filter(replicate %in% input$replicate),
               aes(x = as.factor(treatment),
                   y = property, 
                   fill = as.factor(treatment))
               ) +
            geom_boxplot()+
            geom_jitter(width = 0.1, size = 2) +
            labs(x = "Treatment",
                 y = "Property",
                 title = "Sample Boxplots for Treatment A and B",
                 subtitle = paste("P-value = ", round(p.value, 6), difference))+
            stat_summary(fun.y = "mean",
                         color = "yellow",
                         size = 4,
                         geom = "point")+
            theme(text = element_text(size = 16))+
            guides(fill = guide_legend(title = "Treatment"))+
            guides(color = FALSE)+
            scale_y_continuous(limits = c(input$slider.out.mu - 3* (input$sd.val * 1.5),
                                          input$slider.out.mu * (1 + input$diff.mu / 100) + 3* (input$sd.val * 1.5)
                                          )
                               )+
            coord_flip()
    })
    
    best.sample.size <- reactive({
        n.samples <- pwr.t.test(d = ((input$slider.out.mu * (1 + (input$diff.mu / 100))) - input$slider.out.mu) / input$slider.out.sd,
                            sig.level = input$alpha,
                            power = input$beta,
                            type = c("two.sample")
                            )
        round(as.numeric(n.samples[[1]]), 0)
        })

    output$best.sample.size <- renderText({
        best.sample.size()
        })
    }
)
