library(shiny)
library(shinyjs)
library(shinythemes)
library(shinydashboard)
library(shinyauthr)
library(sodium)
library(shinyalert)
library(DBI)
library(RPostgreSQL)
setwd("/Users/hss/Documents/bazunie/Ski-rental-project")
#source(file='functions.R')


con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'projekt', # nazwa naszej projektowej bazy
                 host = 'localhost',
                 port = '5432', # port ten sam co w psql - zwykle 5432
                 user = 'hela', # nasza nazwa u�ytkownika psql
                 password = 'hela') # i nasze has�o tego u�ytkownika

lokacje <- dbGetQuery(con, "SELECT * FROM lokacje")
pracownicy <- dbGetQuery(con, "SELECT * FROM pracownicy")
stanowiska <- dbGetQuery(con, "SELECT * FROM stanowiska")
kategorie <- dbGetQuery(con, "SELECT * FROM kategorie")
sprzet <- dbGetQuery(con, "SELECT * FROM sprzet")
cennik <- dbGetQuery(con, "SELECT * FROM cennik")
klienci <- dbGetQuery(con, "SELECT * FROM klienci")
rejestr <- dbGetQuery(con, "SELECT * FROM rejestr")





ui <- dashboardPage(
  skin = 'black',
  dashboardHeader(title = "Wypożyczalnia sprzętu narciarskiego \"PANDA 3\"",titleWidth = 450),
  dashboardSidebar(
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
                        tabsetPanel(
                          tabPanel("Wszystkie lokacje", tableOutput('lokacje_lista')),
                          tabPanel("Utwórz lokację",textInput("lokacja_dodanie_nazwa","Podaj nazwę lokacji", value=""),
                                   textInput("lokacja_dodanie_miasto","Podaj miasto", value=""),
                                   textInput("lokacja_dodanie_ulica","Podaj ulicę", value=""),
                                   textInput("lokacja_dodanie_nr","Podaj numer posesji", value=""),
                                   actionButton("dodaj_lokacje","Dodaj lokację")),
                          
                        )
                    )
              ),

      
      
    tabItem(tabName="pracownicy", h2("Pracownicy"),
              fluidPage(
                
              )
    ),
    tabItem(tabName="stanowiska",
              fluidPage(
                theme = shinytheme("flatly")
              )
    ),
    tabItem(tabName="kategorie",
              fluidPage(
                theme = shinytheme("flatly")
              )
    ),
    tabItem(tabName="sprzet",
              fluidPage(
                theme = shinytheme("flatly")
              )
    ),
    tabItem(tabName="cennik",
              fluidPage(
                theme = shinytheme("flatly")
              )
    ),
    tabItem(tabName="klienci",
              fluidPage(
                theme = shinytheme("flatly")
              )
    ),
    tabItem(tabName="rejestr",
              fluidPage(
                theme = shinytheme("flatly")
              )
    )
    )
  )
)

server <- shinyServer(function(input, output, session){
  output$lokacje_lista <- renderTable( dbGetQuery(con, "SELECT id_lokacji, nazwa_lokacji,
                                                  miasto, ulica, nr_posesji FROM lokacje order by 1"), align = "l", width = "100%")


  #guziki lokacje
  #dodaj lokacje
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

shinyApp(ui, server)