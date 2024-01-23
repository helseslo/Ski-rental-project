#install.packages("shiny")
#install.packages("shinyjs")
library(shiny)
library(DT)
library(shinyjs) # ta biblioteka umożliwi łatwe odświeżanie aplikacji
setwd("/Users/hss/Documents/bazunie/Ski-rental-project")
source(file='functions.R')


##### stworzenie interfejsu graficznego aplikacji shiny
##### UWAGA: kodowanie znaków musi być UTF-8

# żeby uruchomić, wystarczy wcisnąć "Run App" w prawym górnym rogu tego okna
shinyUI(fluidPage(
  
  useShinyjs(), # umożliwia wygodne odświeżanie aplikacji
  
  # tytuł naszej aplikacji
  titlePanel("Wypozyczalnia sprzetu narciarskiego"),

  # w tej prostej aplikacji mamy tylko jeden główny panel, który zawiera 4 "taby"
  # oczywiście można dowolnie rozbudowywać interfejs graficzny np. o dodatkowe menu po boku
  mainPanel(
    
    actionButton("refresh", "Refresh"), # przycisk do odświeżania
    
    tabsetPanel(
      
      # pierwszy tab, który wyświetla informacje o wybranym filmie
      tabPanel('Lokacje',
               # pole wyboru nazwy filmu - widoczne filmy pochodzą z naszej bazy danych dzięki funkcji load.movies()
               selectInput(inputId='nazwa_lokacji',
                           label='choose location',
                           choices=load.locations()), # wywołanie funkcji z example_functions.r
               # tabelka z ocenami filmu
               #dataTableOutput('locations.info'), # odwołanie do output$movie.ratings z server.r
               # etykieta ze średnią oceną filmu
               # verbatimTextOutput('locations.info') # odwołanie do output$movie.avg.rating z server.r
               tableOutput('locations.info'),
               
               
               
               textInput(textInput("nowe_id_stanowiska", "id_pracownika_arg"),
                           label='coś'),
                           #choices=load.locations2()), # wywołanie funkcji z example_functions.r
               # tabelka z ocenami filmu
               #dataTableOutput('locations.info'), # odwołanie do output$movie.ratings z server.r
               # etykieta ze średnią oceną filmu
               # verbatimTextOutput('locations.info') # odwołanie do output$movie.avg.rating z server.r
               textOutput('zmiana.stanowiska')
      ),
      
      
      
      
      tabPanel("Lista lokacji",
               tableOutput('lokacje_lista')),
      # drugi tab z informacjami o użytkownikach
      # tabPanel('Users',
      #          selectInput(inputId='login',
      #                      label='choose user',
      #                      choices=load.logins()), # wywołanie funkcji z example_functions.r
      #          dataTableOutput('login.ratings') # odwołanie do output$login.ratings
      # ),
      # 
      
      
      # trzeci tab, służący do aktualizacji ratingów
      # tabPanel('Add or update rating',
      #          
      #          # na początku są 3 pola wyboru: tytułu, użytkownika oraz ratingu     
      #          selectInput(inputId='rating.login',
      #                      label='choose user',
      #                      choices=load.logins()),
      #          selectInput(inputId='rating.title',
      #                      label='choose movie',
      #                      choices=load.movies()),
      #          sliderInput(inputId='rating',
      #                      label='choose rating',
      #                      min=0,max=10,value=10),
      #          
      #          # a na koniec przycisk o identyfikatorze "add.rating", którego obsługa jest w server.r
      #          actionButton(inputId='add.rating',
      #                       label='add or update rating')
      # ),
      # 
      # 
      # # i czwarty tab, służący do dodawania użytkowników do bazy
      # tabPanel('Add user',
      #          # pole tekstowe do wprowadzenia nazwy użytkownika
      #          textInput(inputId='login.to.add',
      #                    label = 'insert user name'),
      #          actionButton(inputId='add.login',
      #                       label='add user')
      #          
      #          
      # )
    )
  )
  
))
