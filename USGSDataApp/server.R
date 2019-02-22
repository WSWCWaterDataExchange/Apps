# server.R
library(ggplot2)
library(XML)
library(RColorBrewer)
library(RCurl)
library(wadeR)

options(RCurlOptions = list(ssl.verifypeer = FALSE))

shinyServer(
  function(input, output, session) {
    
    # This registers these so we can set them in an "observe" over in map.R
    wade_app_label <- "Upper San Juan"
    makeReactiveBinding("wade_app_label")
    wade_app_id <- "14050006"
    makeReactiveBinding("wade_app_id") 
    
    loctxt <- function(x) { # convenience to get loctxt strings
      paste0(x, "-",
             datasets::state.abb[grep(input$state, datasets::state.name)])
    }
    
    source("map.R",local=TRUE)$value # All the map stuff is over in map.R
    
    CU_data_setter <- observe({ # observes for wade_app_id to change from map clicks.
      
      loctxt <- loctxt(wade_app_id)
      
      output$huc <- renderText(paste(loctxt, wade_app_label))
      
      
      wade_url <- paste0('https://wuds-development.usgs.chs.ead/WADE/v0.2/',
                         'GetSummary/GetSummary.php?loctype=REPORTUNIT&loctxt=',
                         loctxt,
                         '&orgid=NWUSP&reportid=',
                         input$year,
                         '-CONSUMPTIVEUSE&datatype=ALL')
      
      CU_df <- get_wade_data(wade_url = wade_url)
      
      #Returns information about the method
      xml.urlCUMethod=getURLContent(paste0('https://wuds-development.usgs.chs.ead/WADE/v0.2/GetMethod/GetMethod.php?methodid=NWUSP&methodname=NOT%20KNOWN'))
      CUmethodroot= xmlRoot(xmlParse(xml.urlCUMethod))
      #Extract Report Summary
      CUmethodsummary=CUmethodroot[["Organization"]][["Method"]]
      CUmethodinfo=xmlSApply(CUmethodsummary,function(x) xmlSApply(x,xmlValue))
      CUmethod_df=data.frame(t(CUmethodinfo),row.names=NULL,stringsAsFactors = FALSE)
      
      #Plots the results from the GetSummary call
      output$CUplot <- renderPlot({
        title="Comparison of Water Use by Sector"
        ggplot(data=CU_df,environment = environment())+
          geom_bar(aes(x=Sector,y=Amount, fill=Sector),stat="identity")+
          theme_bw()+scale_fill_brewer(palette="Paired")+
          xlab("Sector")+ylab("Water Use (acre-feet/year)")+ggtitle(title)+
          theme(legend.position="none",plot.title = element_text(hjust = 0.5))
      })
      
      #List amounts in table
      output$CUtable <- renderTable({
        CU_df=CU_df
      },bordered=TRUE, striped=TRUE)
      
      #Prints the method information
      output$CUmethod <- renderText(
        paste0("For more information about the methods used, see: ",CUmethod_df$MethodLinkText[[1]])
      )
      
    })
    
    Div_data_setter <- observe({ # observes for wade_app_id to change gets new data and rebuilds plots.
      
      loctxt <- loctxt(wade_app_id)
      
      wade_url <- paste0('https://wuds-development.usgs.chs.ead/WADE/v0.2/',
                         'GetSummary/GetSummary.php?loctype=REPORTUNIT&loctxt=',
                         loctxt,
                         '&orgid=NWUSP&reportid=',
                         input$year,
                         '-WITHDRAWALS&datatype=ALL')
      
      Div_df <- get_wade_data(wade_url = wade_url)
      
      #Returns information about the method
      xml.urlDivMethod=getURLContent(paste0('https://wuds-development.usgs.chs.ead/WADE/v0.2/GetMethod/GetMethod.php?methodid=NWUSP&methodname=NOT%20KNOWN'))
      Divmethodroot= xmlRoot(xmlParse(xml.urlDivMethod))
      #Extract Report Summary
      Divmethodsummary=Divmethodroot[["Organization"]][["Method"]]
      Divmethodinfo=xmlSApply(Divmethodsummary,function(x) xmlSApply(x,xmlValue))
      Divmethod_df=data.frame(t(Divmethodinfo),row.names=NULL,stringsAsFactors = FALSE)
      
      #Plots results from the GetSummary call
      output$Divplot <- renderPlot({
        title="Comparison of Diversions by Sector"
        ggplot(data=Div_df,environment = environment())+
          geom_bar(aes(x=Sector,y=Amount, fill=SourceType),stat="identity")+
          theme_bw()+scale_fill_brewer(palette="Paired", name="Source")+
          xlab("Sector")+ylab("Diversions (acre-feet/year)")+ggtitle(title)+
          theme(legend.position="bottom",plot.title = element_text(hjust = 0.5))
      })
      
      #List amounts in table
      output$Divtable <-renderTable({
        Div_df=Div_df
      },bordered=TRUE,striped=TRUE)
      
      
      #Prints the method information
      output$Divmethod <- renderText(
        paste0("For more information about the methods used, see: ",Divmethod_df$MethodLinkText[[1]])
      )
    })
  }
)
