 # Gerekli paketlerin yüklenmesi ve tanımlanması
library(shiny)
library(ggplot2) # Grafik paketi
library(gganimate) # Animasyonlu grafikler için
library(shinythemes) # Shiny temaları için

salaries <- read.csv("salaries.csv") # Shiny uygulamamız için kullanacağımız veriseti tanımlaması

ui <- fluidPage(
  
  titlePanel("Yapay zeka, Makine Öğrenmesi, Veri Maaşları"), #Shiny uygulamamızın ana başlığı
  theme = shinytheme("darkly"), #Shiny uygulaması teması
  sidebarLayout( #Shiny uygulamamızın sol bölümü ve filtrelerimizin olduğu kısım
    sidebarPanel(
      radioButtons(inputId = "filter",
                   label = "Filtreleme İşlemi",
                   choices = list("Filtreleme Yap", "Filtreleme Yapma")),
      
      radioButtons(inputId = "experience_level",
                   label = "İş deneyimi düzeyi : ",
                   choices = list("Giriş seviyesi" = "EN", "Çaylak-Orta seviyesi" = "MI", "Orta-Kıdemli seviyesi" = "SE",
                                  "Uzman-Yönetici seviyesi" = "EX")),
      
      checkboxGroupInput(inputId = "employment_type",
                         label = "Rol için İstihdam türü",
                         choices = c("Yarı zamanlı" = "PT",
                                     "Tam zamanlı" = "FT",
                                     "Sözleşmeli" = "CT",
                                     "Serbest" = "FL")),
      
      selectInput(inputId = "remote_ratio",
                  label = "Uzaktan yapılan toplam iş miktarı",
                  choices = c("Uzaktan çalışma yok" = "0",
                              "Kısmen uzak (Hibrit)" = "50",
                              "Tamamen uzak (Remote)" = "100")),
      
      radioButtons(inputId = "company_size",
                   label = "Yıl boyunca şirket için çalışan ortalama kişi sayısı",
                   choices = list("50'den az çalışan" = "S",
                                  "50 ila 250 çalışan" = "M",
                                  "250'den fazla çalışan" = "L")),
    ),
    
    mainPanel( # Shiny uygulamamızın sağ bölümü, grafiklerimizin, tablomuzun, ve hakkında sayfasının olduğu kısım
      tabsetPanel(#mainpanel kısmının sekmeli olması için kullandığımız panel yapısı
        
        tabPanel("Grafikler", 
                 selectInput(inputId = "plotSelect",
                             label = "Grafik türü seçiniz:",
                             choices = c("Çubuk Grafiği",
                                         "Çizgi Grafiği",
                                         "Pasta Grafiği",
                                         "Dağılım Grafiği")), 
                 plotOutput(outputId = "plot1")),
        tabPanel("Tablolar", dataTableOutput(outputId =  "table1")),
        tabPanel("Rapor", uiOutput(outputId = "report"))
      )
      
    )
  )
)

server <- function(input, output) {# Projemizin backend kısmının işlediği yer
  
  output$report <- renderUI({
    includeHTML("Salaries-Report.html")
  })
  
  filtered_data <- reactive({#kullanıcının yapmış olduğu filtreleme işlemlerinin filtered_data değişkenine atanması 
    if(input$filter == "Filtreleme Yap"){
      filtered <- salaries
      
      if (!is.null(input$experience_level)) {
        filtered <- filtered[filtered$experience_level == input$experience_level,]
      }
      if (!is.null(input$employment_type)) {
        filtered <- filtered[filtered$employment_type %in% input$employment_type,]
      }
      if (!is.null(input$remote_ratio)) {
        filtered <- filtered[filtered$remote_ratio == input$remote_ratio,]
      }
      
      if (!is.null(input$company_size)) {
        filtered <- filtered[filtered$company_size == input$company_size,]
      }
      
      return(filtered)
    } else {
      return(salaries)
    }
  })
  
  output$plot1 <- renderPlot({# yukarıdaki filtered_data değişkenine göre farklı grafik türlerinin çizdirilmesi
    if(input$plotSelect == "Çubuk Grafiği"){
      ggplot(filtered_data(), aes(x = work_year, y = salary_in_usd, fill = factor(work_year))) + 
        geom_bar(stat = "identity") +
        scale_y_continuous(labels = scales::comma) +
        scale_fill_discrete(name = "Çalışma Yılları") +
        labs(x = "Çalışma Yılları", y = "Maaş (USD)") +
        ggtitle("Maaş Dağılımı") 
    }else if(input$plotSelect == "Çizgi Grafiği"){
      ggplot(filtered_data(), aes(x = work_year, y = salary_in_usd)) + geom_line() +
        scale_y_continuous(labels = scales::comma) +
        xlab("Çalışma Yılı") +
        ylab("Maaş (USD)") +
        ggtitle("Yıllara Göre Maaş Dağılımı")
    }else if(input$plotSelect == "Pasta Grafiği"){
      ggplot(filtered_data(), aes(x = "", y = salary_in_usd, fill = factor(work_year))) + geom_bar(stat = "identity", width = 1) +
        scale_y_continuous(labels = scales::comma) +
        labs(x = "", y = "Maaş (USD)", fill = "Çalışma Yılları") +
        coord_polar(theta = "y") +
        ggtitle("Yıllara Göre Maaş Dağılımı")
    }else if(input$plotSelect == "Dağılım Grafiği"){
      ggplot(filtered_data(), aes(x = work_year, y = salary_in_usd)) + geom_point() +
        scale_y_continuous(labels = scales::comma) +
        labs(x = "Çalışma Yılları", y = "Maaş (USD)") +
        ggtitle("Yıllara Göre Maaş Dağılımı")
    }
  })
  
  
  output$table1 <- renderDataTable(filtered_data())
  
}

#Shiny uygulamasının çalıştırılması
shinyApp(ui = ui, server = server)