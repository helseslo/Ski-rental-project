library(shiny)
library(shinyjs)
library(shinythemes)
library(shinydashboard)
library(shinyauthr)
library(sodium)
library(shinyalert)
library(DBI)
library(RPostgreSQL)
library(shinyBS)
library(DT)
setwd("/Users/hss/Documents/bazunie/Ski-rental-project")
#source(file='functions.R')


con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'projekt', # nazwa naszej projektowej bazy
                 host = 'localhost',
                 port = '5432', # port ten sam co w psql - zwykle 5432
                 user = 'hela', # nasza nazwa u�ytkownika psql
                 password = 'hela') # i nasze has�o tego u�ytkownika

# obiekty do rendertable do outputu w sekcji serwer;
# Całe podstawowe tabele 
lokacje <- dbGetQuery(con, "SELECT * FROM lokacje")
pracownicy <- dbGetQuery(con, "SELECT * FROM pracownicy")
stanowiska <- dbGetQuery(con, "SELECT * FROM stanowiska")
kategorie <- dbGetQuery(con, "SELECT * FROM kategorie")
sprzet <- dbGetQuery(con, "SELECT * FROM sprzet")
cennik <- dbGetQuery(con, "SELECT * FROM cennik")
klienci <- dbGetQuery(con, "SELECT * FROM klienci")
rejestr <- dbGetQuery(con, "SELECT * FROM rejestr")
# Widoki
top_lokacje <- dbGetQuery(con, "SELECT * FROM top_lokacje")
top_sprzet <- dbGetQuery(con, "SELECT * FROM top_sprzet")



ui <- tagList(
  tags$style("html,body{background-color: white;}
                .container{
                    width: 100%;
                    margin: 0 auto;
                    padding: 0;
                    font-size: 13px;
                }
                #myimg{
                    width:100%;
                }
               @media screen and (min-width: 800px){
                .container{
                    width: 1920px;
                    height: 1080px;
                }
               }"),
  tags$div(class="container", dashboardPage(
  skin = 'black',
  dashboardHeader(title = "Wypożyczalnia sprzętu narciarskiego \"PANDA 3\"",titleWidth = 450),
  dashboardSidebar(
    width = 120,
    sidebarMenu(
      menuItem('Lokacje', tabName="lokacje", icon=icon("house")),
      menuItem('Pracownicy', tabName="pracownicy", icon=icon("user")),
      menuItem('Stanowiska', tabName="stanowiska", icon=icon("briefcase")),
      menuItem('Kategorie', tabName="kategorie", icon=icon("list")),
      menuItem('Sprzęt', tabName="sprzet", icon=icon("person-skiing")),
      menuItem('Cennik', tabName="cennik", icon=icon("dollar-sign")),
      menuItem('Klienci', tabName="klienci", icon=icon("users")),
      menuItem('Rejestr', tabName="rejestr", icon=icon("list-ol"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName="lokacje", h2("Lokacje"),
              fluidPage(theme = shinytheme("flatly"),
                        height = '100%',
                        tabsetPanel(
                          tabPanel("Wszystkie lokacje", dataTableOutput('lokacje_lista', width="60%")),
                          tabPanel("Utwórz lokację",textInput("lokacja_dodanie_nazwa","Podaj nazwę lokacji", value=""),
                                   textInput("lokacja_dodanie_miasto","Podaj miasto", value=""),
                                   textInput("lokacja_dodanie_ulica","Podaj ulicę", value=""),
                                   textInput("lokacja_dodanie_nr","Podaj numer posesji", value=""),
                                   actionButton("dodaj_lokacje","Dodaj lokację")),
                          tabPanel("Top lokacje", dataTableOutput('top_lokacje_lista', width="30%")),
                          
                        )
                    )
              ),

      
      
    tabItem(tabName="pracownicy", h2("Pracownicy"),
              fluidPage(theme = shinytheme("flatly"),
                         tabsetPanel(
                           tabPanel("Wszyscy pracownicy", dataTableOutput ('pracownicy_lista', width="50%")),
                           
                         )
              )
    ),
    tabItem(tabName="stanowiska", h2("Stanowiska"),
              fluidPage(
                theme = shinytheme("flatly"),
                tabsetPanel(
                  tabPanel("Wszystkie stanowiska", dataTableOutput ('stanowiska_lista', width="30%")),
                  
                )
              )
    ),
    tabItem(tabName="kategorie", h2("Kategorie"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Wszystkie kategorie", dataTableOutput ('kategorie_lista', width="30%")),
                
              )
            )
    ),
    tabItem(tabName="sprzet", h2("Sprzęt"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Cały sprzęt", dataTableOutput ('sprzet_lista', width="70%")),
                tabPanel("Top sprzęt", dataTableOutput('top_sprzet_lista', width="40%")),
                
              )
            )
    ),
    tabItem(tabName="cennik", h2("Cennik"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Wszystkie ceny i kary", dataTableOutput ('cennik_lista', width="50%")),
                
              )
            )
    ),
    tabItem(tabName="klienci", h2("Klienci"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Wszyscy klienci", dataTableOutput ('klienci_lista', width="70%")),
                
              )
            )
      ),
    tabItem(tabName="rejestr", h2("Rejestr"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Pełny rejestr", dataTableOutput ('rejestr_lista', width = "70%")),
                
              )
            )
      )
      )
    )
  )
  )
)

server <- shinyServer(function(input, output, session){
  
  # RENDERY do datatable do wyświetlenia
  # Główne tabele
  output$lokacje_lista <- renderDataTable( dbGetQuery(con, "SELECT id_lokacji, nazwa_lokacji,
                                                  miasto, ulica, nr_posesji FROM lokacje order by 1"))
  output$pracownicy_lista = renderDataTable(pracownicy)
  output$stanowiska_lista = renderDataTable(stanowiska)
  output$kategorie_lista = renderDataTable(kategorie)
  output$sprzet_lista = renderDataTable(sprzet)
  output$cennik_lista = renderDataTable(cennik)
  output$klienci_lista = renderDataTable(klienci)
  output$rejestr_lista = DT::renderDataTable({datatable(rejestr) %>% formatDate(4:6, "toLocaleString")})
  
  # Widoki
  output$top_lokacje_lista = renderDataTable(top_lokacje)
  output$top_sprzet_lista = renderDataTable(top_sprzet)

  # GUZIKI
  # lokacje
  # dodaj lokacje
  observeEvent(input$dodaj_lokacje, {
  
    res <- dbSendStatement(con, paste0("select dodaj_lokacje(","'",input$lokacja_dodanie_nazwa,"'", ",", "'",
                                       input$lokacja_dodanie_miasto,"'", ",", "'",
                                       input$lokacja_dodanie_ulica, "'", ",",
                                       input$lokacja_dodanie_nr, ")"))
    data <- dbFetch(res)
    updateTextInput(session,"lokacja_dodanie_nazwa", value="")
    updateTextInput(session,"lokacja_dodanie_miasto", value="")
    updateTextInput(session,"lokacja_dodanie_ulica", value="")
    updateTextInput(session,"lokacja_dodanie_nr", value="")
    output$lokacje_lista <- renderTable( dbGetQuery(con, "SELECT id_lokacji, nazwa_lokacji,
                                                  miasto, ulica, nr_posesji FROM lokacje order by 1"), align = "l", width = "100%")
    shinyalert(print(data[1,1]), type = "info")
  })
  

})

shinyApp(ui, server, options = list(height = 1080))
