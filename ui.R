#install.packages("shiny")
#install.packages("shinyjs")
library(shinythemes)
library(shiny)
library(DT)
library(shinyjs) # ta biblioteka umożliwi łatwe odświeżanie aplikacji
setwd("/Users/hss/Documents/bazunie/Ski-rental-project")
source(file='functions.R')


##### stworzenie interfejsu graficznego aplikacji shiny

shinyUI(fluidPage(
  

  useShinyjs(), # umożliwia wygodne odświeżanie aplikacji
  skin = 'black',
  # tytuł naszej aplikacji
  titlePanel("WITAMY W SIECI WYPOŻYCZALNI SPRZĘTU NARCIASKIEGO \"PANDA 3\"!"),

  # w tej prostej aplikacji mamy tylko jeden główny panel, który zawiera 4 "taby"
  # oczywiście można dowolnie rozbudowywać interfejs graficzny np. o dodatkowe menu po boku
  
  theme = shinytheme("flatly"),
  mainPanel(
    
    actionButton("refresh", "Odśwież"), # przycisk do odświeżania
    
    tabsetPanel(
      
      # pierwszy tab, który wyświetla informacje o wybranym filmie
      tabPanel('Lokacje',
               # pole wyboru nazwy filmu - widoczne filmy pochodzą z naszej bazy danych dzięki funkcji load.movies()
               selectInput(inputId='nazwa_lokacji',
                           label='Wybierz lokację',
                           choices=load.locations()), # wywołanie funkcji z example_functions.r
               # tabelka z ocenami filmu
               #dataTableOutput('locations.info'), # odwołanie do output$movie.ratings z server.r
               # etykieta ze średnią oceną filmu
               # verbatimTextOutput('locations.info') # odwołanie do output$movie.avg.rating z server.r
               tableOutput('locations.info'),
      ),
      

      tabPanel('Zmiana stanowiska',
               
               selectInput(inputId='pracownicy.id_pracownika',
                           label='Wybierz ID pracownika',
                           choices=load.pracownicy()),
               selectInput(inputId='stanowiska.id_stanowiska',
                           label='Wybierz ID nowego stanowiska',
                           choices=load.stanowiska()),


               actionButton(inputId='zmiana.stanowiska',
                            label='Potwierdź')
      ),

      tabPanel('Pracownicy',
               selectInput(inputId='id_pracownika',
                           label='Wybierz ID pracownika',
                           choices=load.pracownicy()), # wywołanie funkcji z example_functions.r
               # tabelka z ocenami filmu
               #dataTableOutput('locations.info'), # odwołanie do output$movie.ratings z server.r
               # etykieta ze średnią oceną filmu
               # verbatimTextOutput('locations.info') # odwołanie do output$movie.avg.rating z server.r
               tableOutput('pracownicy.info'),
      ),
      
    )
  )
  
))
