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
czarna_lista <- dbGetQuery(con, "SELECT * FROM klienci_na_czarnej_liscie")



# zaczynamy UI, czyli to, co widać :)
ui <- tagList(
  # ustawienia wielkości strony, koloru tła itd.
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
  # podrasowanie koloru paska bocznego
  skin = 'black',
  # nagłówek - lewy górny róg
  dashboardHeader(title = "Wypożyczalnia sprzętu narciarskiego \"PANDA 3\"",titleWidth = 450),
  # Pasek boczny - tytuły, ikonki i nazwy tabów, czyli podstron
  dashboardSidebar(
    width = 140,
    sidebarMenu(
      menuItem('Strona główna', tabName="glowna", icon=icon("house")),
      menuItem('Lokacje', tabName="lokacje", icon=icon("location-dot")),
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
    # tabItem to jedna podstrona w pasku bocznym; nazwa tabName musi się zgadzać z nazwami piętro wyżej! h2 to tytuł
    tabItems(
      tabItem(tabName="glowna", h2("Strona główna"),
              fluidPage(
                theme = shinytheme("flatly"),
                tabsetPanel(
                  tabPanel("Przychód w podanym zakresie dat",
                           h3("Sprawdź sumaryczny przychód w podanym zakresie"),
                           dateInput("przychod_data_od","Data początkowa:", "", format = 'yyyy-mm-dd'),
                           dateInput("przychod_data_do","Data końcowa:", "", format = 'yyyy-mm-dd', max=Sys.Date()),
            
                           actionButton("sprawdz_przychod","Sprawdź przychód")),
                  tabPanel("Przychód dla lokacji w podanym zakresie dat",
                           h3("Sprawdź sumaryczny przychód dla lokacji w podanym zakresie"),
                           dateInput("przychod_lokacja_data_od","Data początkowa:", "", format = 'yyyy-mm-dd'),
                           dateInput("przychod_lokacja_data_do","Data końcowa:", "", format = 'yyyy-mm-dd', max=Sys.Date()),
                           selectInput('sprawdz_przychod_id_lokacji', 'Wybierz id lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                           actionButton("sprawdz_przychod_lokacja","Sprawdź przychód")),

                  
                )
              )
      ),
      tabItem(tabName="lokacje", h2("Lokacje"),
              fluidPage(theme = shinytheme("flatly"),
                        height = '100%',
                        tabsetPanel(
                          # zakładki na stronie (w poziomie)
                          
                          # tabela
                          tabPanel("Wszystkie lokacje", dataTableOutput('lokacje_lista', width="60%")),
                          
                          # funkcja do tworzenia lokacji
                          tabPanel("Dodaj lokację",
                                   textInput("lokacja_dodanie_nazwa","Podaj nazwę lokacji", value=""),
                                   textInput("lokacja_dodanie_miasto","Podaj miasto", value=""),
                                   textInput("lokacja_dodanie_ulica","Podaj ulicę", value=""),
                                   textInput("lokacja_dodanie_nr","Podaj numer posesji", value=""),
                                   actionButton("dodaj_lokacje","Dodaj lokację")),
                          
                          # funkcja do zmieniania danych lokacji
                          tabPanel("Zmień dane lokacji",
                                   selectInput('lokacja_zmiana_id_lokacji', 'Wybierz id lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                                   textInput("lokacja_zmiana_nazwa","Podaj nową nazwę lokacji", value=""),
                                   textInput("lokacja_zmiana_miasto","Podaj nowe miasto", value=""),
                                   textInput("lokacja_zmiana_ulica","Podaj nową ulicę", value=""),
                                   textInput("lokacja_zmiana_nr","Podaj nowy numer posesji", value=""),
                                   actionButton("zmien_lokacje","Zmień dane lokacji")),
                          
                          # widok
                          tabPanel("Top lokacje", dataTableOutput('top_lokacje_lista', width="30%")),
                          
                        )
                    )
              ),

      
      
    tabItem(tabName="pracownicy", h2("Pracownicy"),
              fluidPage(theme = shinytheme("flatly"),
                         tabsetPanel(
                           tabPanel("Wszyscy pracownicy", dataTableOutput ('pracownicy_lista', width="50%")),
                           tabPanel("Dodaj pracownika",
                                    textInput("pracownik_dodanie_imie","Podaj imię", value=""),
                                    textInput("pracownik_dodanie_nazwisko","Podaj nazwisko", value=""),
                                    selectInput('pracownik_dodanie_id_lokacji', 'Wybierz id lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                                    selectInput('pracownik_dodanie_id_stanowiska', 'Wybierz id stanowiska', choices =c(" ",dbGetQuery(con, "SELECT id_stanowiska FROM stanowiska order by 1"))),
                                    actionButton("dodaj_pracownika","Dodaj pracownika")),
                           tabPanel("Zmień dane pracownika",
                                    selectInput('pracownik_zmiana_id_pracownika', 'Wybierz id pracownika', choices =c(" ",dbGetQuery(con, "SELECT id_pracownika FROM pracownicy order by 1"))),
                                    textInput("pracownik_zmiana_imie","Podaj nowe imię", value=""),
                                    textInput("pracownik_zmiana_nazwisko","Podaj nowe nazwisko", value=""),
                                    selectInput('pracownik_zmiana_id_lokacji', 'Wybierz id nowej lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                                    selectInput('pracownik_zmiana_id_stanowiska', 'Wybierz nowe id stanowiska', choices =c(" ",dbGetQuery(con, "SELECT id_stanowiska FROM stanowiska order by 1"))),
                                    actionButton("zmien_pracownika","Zmień dane pracownika")),
                           tabPanel("Zwolnij pracownika",
                                    selectInput('pracownik_usun_id_pracownika', 'Wybierz id pracownika', choices =c(" ",dbGetQuery(con, "SELECT id_pracownika FROM pracownicy order by 1"))),
                                    actionButton("zwolnij_pracownika","Zwolnij pracownika")),
                           
                         )
              )
    ),
    tabItem(tabName="stanowiska", h2("Stanowiska"),
              fluidPage(
                theme = shinytheme("flatly"),
                tabsetPanel(
                  tabPanel("Wszystkie stanowiska", dataTableOutput ('stanowiska_lista', width="30%")),
                  tabPanel("Dodaj stanowisko",
                           textInput("stanowisko_dodanie_nazwa","Podaj nazwę", value=""),
                           actionButton("dodaj_stanowisko","Dodaj stanowisko")),
                  tabPanel("Zmień nazwę stanowiska",
                           selectInput('stanowisko_zmiana_id_stanowiska', 'Wybierz id stanowiska', choices =c(" ",dbGetQuery(con, "SELECT id_stanowiska FROM stanowiska order by 1"))),
                           textInput("stanowisko_zmiana_nazwa","Podaj nową nazwę", value=""),
                           actionButton("zmien_stanowisko","Zmień nazwę stanowiska")),
                  
                )
              )
    ),
    tabItem(tabName="kategorie", h2("Kategorie"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Wszystkie kategorie", dataTableOutput ('kategorie_lista', width="30%")),
                tabPanel("Dodaj kategorię",
                         textInput("kategoria_dodanie_nazwa","Podaj nazwę", value=""),
                         actionButton("dodaj_kategorie","Dodaj kategorię")),
                tabPanel("Zmień nazwę kategorii",
                         selectInput('kategoria_zmiana_id_kategorii', 'Wybierz id kategorii', choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1"))),
                         textInput("kategoria_zmiana_nazwa","Podaj nową nazwę", value=""),
                         actionButton("zmien_kategorie","Zmień nazwę kategorii")),
                
              )
            )
    ),
    tabItem(tabName="sprzet", h2("Sprzęt"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Cały sprzęt", dataTableOutput ('sprzet_lista', width="70%")),
                tabPanel("Dodaj sprzęt",
                         selectInput('sprzet_dodanie_id_kategorii', 'Wybierz id kategorii', choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1"))),
                         textInput("sprzet_dodanie_rozmiar","Podaj rozmiar", value=""),
                         textInput("sprzet_dodanie_firma","Podaj firmę", value=""),
                         selectInput('sprzet_dodanie_id_lokacji', 'Wybierz id lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                         actionButton("dodaj_sprzet","Dodaj sprzęt")),
                tabPanel("Zmień lokalizację sprzętu",
                         selectInput('sprzet_zmiana_id_sprzetu', 'Wybierz id sprzętu', choices =c(" ",dbGetQuery(con, "SELECT id_sprzetu FROM sprzet WHERE stan_wypozyczenia = FALSE order by 1"))),
                         selectInput('sprzet_zmiana_id_lokacji', 'Wybierz id nowej lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                         actionButton("zmien_sprzet","Zmień lokalizację sprzętu")),
                tabPanel("Top sprzęt", dataTableOutput('top_sprzet_lista', width="40%")),
                
                
              )
            )
    ),
    tabItem(tabName="cennik", h2("Cennik"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Wszystkie ceny i kary", dataTableOutput ('cennik_lista', width="50%")),
                tabPanel("Dodaj pozycję do cennika",
                         textInput("cennik_dodanie_cena","Podaj cenę", value=""),
                         textInput("cennik_dodanie_kara","Podaj karę", value=""),
                         selectInput('cennik_dodanie_id_lokacji', 'Wybierz id lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                         selectInput('cennik_dodanie_id_kategorii', 'Wybierz id kategorii', choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1"))),
                         actionButton("dodaj_cennik","Dodaj cennik")),
                tabPanel("Zmień cennik",
                         selectInput('cennik_zmiana_id_lokacji', 'Wybierz id lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                         selectInput('cennik_zmiana_id_kategorii', 'Wybierz id kategorii', choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1"))),
                         textInput("cennik_zmiana_cena","Podaj nową cenę", value=""),
                         textInput("cennik_zmiana_kara","Podaj nową karę", value=""),
                         actionButton("zmien_cennik","Zmień cennik")),
                tabPanel("Zmień cennik o %",
                         selectInput('cennik_zmiana_procent_id_lokacji', 'Wybierz id lokacji', choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1"))),
                         selectInput('cennik_zmiana_procent_id_kategorii', 'Wybierz id kategorii', choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1"))),
                         textInput("cennik_zmiana_procent_cena","Podaj procent, o jaki chcesz zmienić cenę 
                                   (poprzedź go -, jeśli chcesz ją obniżyć)", value=""),
                         textInput("cennik_zmiana_procent_kara","Podaj procent, o jaki chcesz zmienić karę 
                                   (poprzedź go -, jeśli chcesz ją obniżyć)", value=""),
                         actionButton("zmien_cennik_procent","Zmień cennik o procent")),
                
              )
                
              
            )
    ),
    tabItem(tabName="klienci", h2("Klienci"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Wszyscy klienci", dataTableOutput ('klienci_lista', width="70%")),
                tabPanel("Dodaj klienta",
                         textInput("klient_dodanie_imie","Podaj imię", value=""),
                         textInput("klient_dodanie_nazwisko","Podaj nazwisko", value=""),
                         textInput('klient_dodanie_nr_telefonu', "Podaj numer telefonu", value=""),
                         textInput('klient_dodanie_nr_dowodu', "Podaj numer dowodu", value=""),
                         textInput('klient_dodanie_pesel', "Podaj numer PESEL", value=""),
                         actionButton("dodaj_klienta","Dodaj klienta")),
                tabPanel("Zmień dane klienta",
                         selectInput('klient_zmiana_id_klienta', 'Wybierz id klienta', choices =c(" ",dbGetQuery(con, "SELECT id_klienta FROM klienci order by 1"))),
                         textInput("klient_zmiana_imie","Podaj nowe imię", value=""),
                         textInput("klient_zmiana_nazwisko","Podaj nowe nazwisko", value=""),
                         textInput("klient_zmiana_nr_telefonu","Podaj nowy numer telefonu", value=""),
                         textInput("klient_zmiana_nr_dowodu","Podaj nowy numer dowodu", value=""),
                         textInput("klient_zmiana_pesel","Podaj nowy numer PESEL", value=""),
                         selectInput('klient_zmiana_czarna_lista', 'Wybierz, czy klient ma być na czarnej liście', choices =c(FALSE, TRUE)),
                         actionButton("zmien_klienta","Zmień dane klienta")),
                tabPanel("Czarna lista", dataTableOutput('czarna_lista', width="50%")),
                
              )
            )
      ),
    tabItem(tabName="rejestr", h2("Rejestr"),
            fluidPage(
              theme = shinytheme("flatly"),
              tabsetPanel(
                tabPanel("Pełny rejestr", dataTableOutput ('rejestr_lista', width = "70%")),
                tabPanel("Wypożyczenie",
                         selectInput('wypozycz_id_sprzetu', 'Wybierz id sprzętu', choices =c(" ",dbGetQuery(con, "SELECT id_sprzetu FROM sprzet WHERE stan_wypozyczenia=FALSE order by id_sprzetu"))),
                         selectInput('wypozycz_id_klienta', 'Wybierz id klienta', choices =c(" ",dbGetQuery(con, "SELECT id_klienta FROM klienci ORDER BY id_klienta"))),
                         dateInput("wypozycz_data_zwrotu","Podaj datę zwrotu", "", format = 'yyyy-mm-dd', min=Sys.Date()),
                         actionButton("wypozycz","Wypożycz")),
                tabPanel("Zwrot",
                         selectInput('zwrot_id_wypozyczenia', 'Wybierz id wypozyczenia', choices =c(" ",dbGetQuery(con, "SELECT id_wypozyczenia FROM rejestr WHERE czy_aktualne=TRUE order by id_wypozyczenia"))),
                         actionButton("zwrot","Dokonaj zwrotu")),
                
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
  output$rejestr_lista = DT::renderDataTable({datatable(rejestr) %>% formatDate(4:6, method =  "toLocaleDateString", 
                                                                                params = list(
                                                                                  'en-ca', 
                                                                                  list(
                                                                                    year = 'numeric', 
                                                                                    month = 'numeric',
                                                                                    day = 'numeric')
                                                                                ))})
  
  # Widoki
  output$top_lokacje_lista = renderDataTable(top_lokacje)
  output$top_sprzet_lista = renderDataTable(top_sprzet)
  output$czarna_lista_lista = renderDataTable(top_sprzet)
  
  # GUZIKI
  # główna
  # sprawdź przychód
  observeEvent(input$sprawdz_przychod, {
    
    res <- dbSendStatement(con, paste0("SELECT sumaryczny_przychod_zakres_id(","'",input$przychod_data_od,"'", ",", "'",
                                       input$przychod_data_do,"'",")"))
    data <- dbFetch(res)
    updateDateInput(session, 'przychod_data_od', value=NA)
    updateDateInput(session, 'przychod_data_do', value=NA, max=Sys.Date())
    shinyalert(print(data[1,1]), type = "info")
  })
  # sprawdź przychód dla lokacji
  observeEvent(input$sprawdz_przychod_lokacja, {
    
    res <- dbSendStatement(con, paste0("SELECT sumaryczny_przychod_zakres_id(","'",input$przychod_lokacja_data_od,"'", ",", "'",
                                       input$przychod_lokacja_data_do,"'", ",", "'",
                                       input$sprawdz_przychod_id_lokacji, "'",")"))
    data <- dbFetch(res)
    updateDateInput(session, 'przychod_lokacja_data_od', value=NA)
    updateDateInput(session, 'przychod_lokacja_data_do',value=NA, max=Sys.Date())
    updateSelectInput(session, 'sprawdz_przychod_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    shinyalert(print(data[1,1]), type = "info")
  })

  
  
  
  # lokacje
  # dodaj lokacje
  observeEvent(input$dodaj_lokacje, {
  
    res <- dbSendStatement(con, paste0("select dodaj_lokacje(","'",input$lokacja_dodanie_nazwa,"'", ",", "'",
                                       input$lokacja_dodanie_miasto,"'", ",", "'",
                                       input$lokacja_dodanie_ulica, "'", ",", "'",
                                       input$lokacja_dodanie_nr, "'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'lokacja_dodanie_nazwa', value="")
    updateTextInput(session,'lokacja_dodanie_miasto', value="")
    updateTextInput(session,'lokacja_dodanie_ulica', value="")
    updateTextInput(session,'lokacja_dodanie_nr', value="")
    output$lokacje_lista <- renderDataTable( dbGetQuery(con, "SELECT id_lokacji, nazwa_lokacji,
                                                  miasto, ulica, nr_posesji FROM lokacje order by 1"))
    output$top_lokacje_lista = renderDataTable(top_lokacje)
    shinyalert(print(data[1,1]), type = "info")
  })
  # zmien dane lokacji
  observeEvent(input$zmien_lokacje, {
    
    res <- dbSendStatement(con, paste0("select zmien_dane_lokacji(","'",input$lokacja_zmiana_id_lokacji,"'", ",", "'",
                                       input$lokacja_zmiana_nazwa,"'", ",", "'",
                                       input$lokacja_zmiana_miasto,"'", ",", "'",
                                       input$lokacja_zmiana_ulica, "'", ",", "'",
                                       input$lokacja_zmiana_nr, "'", ")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'lokacja_zmiana_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    updateTextInput(session,'lokacja_zmiana_nazwa', value="")
    updateTextInput(session,'lokacja_zmiana_miasto', value="")
    updateTextInput(session,'lokacja_zmiana_ulica', value="")
    updateTextInput(session,'lokacja_zmiana_nr', value="")
    output$lokacje_lista <- renderDataTable( dbGetQuery(con, "SELECT id_lokacji, nazwa_lokacji,
                                                  miasto, ulica, nr_posesji FROM lokacje order by 1"))
    output$top_lokacje_lista = renderDataTable(top_lokacje)
    shinyalert(print(data[1,1]), type = "info")
  })
  
  # pracownicy
  # dodaj pracownika
  observeEvent(input$dodaj_pracownika, {
    
    res <- dbSendStatement(con, paste0("select dodaj_pracownika(","'",input$pracownik_dodanie_imie,"'", ",", "'",
                                       input$pracownik_dodanie_nazwisko,"'", ",", "'",
                                       input$pracownik_dodanie_id_lokacji, "'",",", "'",
                                       input$pracownik_dodanie_id_stanowiska, "'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'pracownik_dodanie_imie', value="")
    updateTextInput(session,'pracownik_dodanie_nazwisko', value="")
    updateSelectInput(session, 'pracownik_dodanie_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    updateSelectInput(session, 'pracownik_dodanie_id_stanowiska', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_stanowiska FROM stanowiska order by 1")), selected = NULL)
    output$pracownicy_lista <- renderDataTable( dbGetQuery(con, "SELECT id_pracownika, imie,
                                                  nazwisko, id_lokacji, id_stanowiska FROM pracownicy order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  # zmien dane pracownika
  observeEvent(input$zmien_pracownika, {
    
    res <- dbSendStatement(con, paste0("select zmien_dane_pracownika(","'",input$pracownik_zmiana_id_pracownika,"'", ",", "'",
                                       input$pracownik_zmiana_imie,"'", ",", "'",
                                       input$pracownik_zmiana_nazwisko,"'", ",", "'",
                                       input$pracownik_zmiana_id_lokacji, "'",",", "'",
                                       input$pracownik_zmiana_id_stanowiska, "'", ")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'pracownik_zmiana_id_pracownika', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_pracownika FROM pracownicy order by 1")), selected = NULL)
    updateTextInput(session,'pracownik_zmiana_imie', value="")
    updateTextInput(session,'pracownik_zmiana_nazwisko', value="")
    updateSelectInput(session, 'pracownik_zmiana_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    updateSelectInput(session, 'pracownik_zmiana_id_stanowiska', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_stanowiska FROM stanowiska order by 1")), selected = NULL)
    output$pracownicy_lista <- renderDataTable( dbGetQuery(con, "SELECT id_pracownika, imie,
                                                  nazwisko, id_lokacji, id_stanowiska FROM pracownicy order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  # zwolnij pracownika
  observeEvent(input$zwolnij_pracownika, {
    
    res <- dbSendStatement(con, paste0("select zwolnij_pracownika(","'",input$pracownik_usun_id_pracownika,"'",")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'pracownik_usun_id_pracownika', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_pracownika FROM pracownicy order by 1")), selected = NULL)
    output$pracownicy_lista <- renderDataTable( dbGetQuery(con, "SELECT id_pracownika, imie,
                                                  nazwisko, id_lokacji, id_stanowiska FROM pracownicy order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  
  # stanowiska
  # dodaj stanowisko
  observeEvent(input$dodaj_stanowisko, {
    
    res <- dbSendStatement(con, paste0("select dodaj_stanowisko(","'",input$stanowisko_dodanie_nazwa,"'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'stanowisko_dodanie_nazwa', value="")
    output$stanowiska_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM stanowiska order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  # zmiana nazwy stanowiska
  observeEvent(input$zmien_stanowisko, {
    
    res <- dbSendStatement(con, paste0("select zmien_nazwe_stanowiska(","'",input$stanowisko_zmiana_id_stanowiska,
                                       "'", ",", "'",input$stanowisko_zmiana_nazwa,"'",")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'stanowisko_zmiana_id_stanowiska', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_stanowiska FROM stanowiska order by 1")), selected = NULL)
    updateTextInput(session,'stanowisko_zmiana_nazwa', value="")
    output$stanowiska_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM stanowiska order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  
  # kategorie
  # dodaj kategorię
  observeEvent(input$dodaj_kategorie, {
    
    res <- dbSendStatement(con, paste0("select dodaj_kategorie(","'",input$kategoria_dodanie_nazwa,"'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'kategoria_dodanie_nazwa', value="")
    output$kategorie_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM kategorie order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  # zmiana nazwy kategorii
  observeEvent(input$zmien_kategorie, {
    
    res <- dbSendStatement(con, paste0("select zmien_nazwe_kategorii(",input$kategoria_zmiana_id_kategorii,
                                       ",", "'",input$kategoria_zmiana_nazwa,"'",")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'kategoria_zmiana_id_kategorii', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1")), selected = NULL)
    updateTextInput(session,'kategoria_zmiana_nazwa', value="")
    output$kategorie_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM kategorie order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  
  # sprzet
  # dodaj sprzet
  observeEvent(input$dodaj_sprzet, {
    
    res <- dbSendStatement(con, paste0("select dodaj_sprzet(","'",input$sprzet_dodanie_id_kategorii,"'", ",", "'",
                                       input$sprzet_dodanie_rozmiar,"'", ",", "'",
                                       input$sprzet_dodanie_firma, "'", ",","'",
                                       input$sprzet_dodanie_id_lokacji,"'", ")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'sprzet_dodanie_id_kategorii', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1")), selected = NULL)
    updateTextInput(session,'sprzet_dodanie_rozmiar', value="")
    updateTextInput(session,'sprzet_dodanie_firma', value="")
    updateSelectInput(session, 'sprzet_dodanie_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    output$sprzet_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM sprzet order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  # zmien lokalizacje sprzetu
  observeEvent(input$zmien_sprzet, {
    
    res <- dbSendStatement(con, paste0("select zmien_lokacje_sprzetu(","'",input$sprzet_zmiana_id_sprzetu,"'", ",", "'",
                                       input$sprzet_zmiana_id_lokacji,"'", ")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'sprzet_zmiana_id_sprzetu', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_sprzetu FROM sprzet WHERE stan_wypozyczenia = FALSE order by 1")), selected = NULL)
    updateSelectInput(session, 'sprzet_zmiana_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    output$sprzet_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM sprzet order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  
  # cennik
  # dodaj cennik
  observeEvent(input$dodaj_cennik, {
    
    res <- dbSendStatement(con, paste0("select dodaj_cene(","'",input$cennik_dodanie_cena,"'", ",", "'",
                                       input$cennik_dodanie_kara,"'", ",", "'",
                                       input$cennik_dodanie_id_lokacji, "'", ",","'",
                                       input$cennik_dodanie_id_kategorii,"'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'cennik_dodanie_cena', value="")
    updateTextInput(session,'cennik_dodanie_kara', value="")
    updateSelectInput(session, 'cennik_dodanie_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    
    updateSelectInput(session, 'cennik_dodanie_id_kategorii', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1")), selected = NULL)
    output$cennik_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM cennik order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  # zmień cennik
  observeEvent(input$zmien_cennik, {
    
    res <- dbSendStatement(con, paste0("select zmien_cennik(","'",input$cennik_zmiana_cena,"'", ",", "'",
                                       input$cennik_zmiana_kara,"'", ",", "'",
                                       input$cennik_zmiana_id_lokacji, "'", ",","'",
                                       input$cennik_zmiana_id_kategorii,"'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'cennik_zmiana_cena', value="")
    updateTextInput(session,'cennik_zmiana_kara', value="")
    updateSelectInput(session, 'cennik_zmiana_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    
    updateSelectInput(session, 'cennik_zmiana_id_kategorii', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1")), selected = NULL)
    output$cennik_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM cennik order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  
  # zmień cennik o %
  observeEvent(input$zmien_cennik_procent, {
    
    res <- dbSendStatement(con, paste0("select zmien_cennik_o_procent(","'",input$cennik_zmiana_procent_cena,"'", ",", "'",
                                       input$cennik_zmiana_procent_kara,"'", ",", "'",
                                       input$cennik_zmiana_procent_id_lokacji, "'", ",","'",
                                       input$cennik_zmiana_procent_id_kategorii,"'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'cennik_zmiana_procent_cena', value="")
    updateTextInput(session,'cennik_zmiana_procent_kara', value="")
    updateSelectInput(session, 'cennik_zmiana_procent_id_lokacji', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_lokacji FROM lokacje order by 1")), selected = NULL)
    
    updateSelectInput(session, 'cennik_zmiana_procent_id_kategorii', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_kategorii FROM kategorie order by 1")), selected = NULL)
    output$cennik_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM cennik order by 1"))
    shinyalert(print(data[1,1]), type = "info")
  })
  
  # klienci
  # dodaj klienta
  observeEvent(input$dodaj_klienta, {
    
    res <- dbSendStatement(con, paste0("select dodaj_klienta(","'",input$klient_dodanie_imie,"'", ",", "'",
                                       input$klient_dodanie_nazwisko,"'", ",", "'",
                                       input$klient_dodanie_nr_telefonu,"'", ",", "'",
                                       input$klient_dodanie_nr_dowodu,"'", ",", "'",
                                       input$klient_dodanie_pesel,"'", ")"))
    data <- dbFetch(res)
    updateTextInput(session,'klient_dodanie_imie', value="")
    updateTextInput(session,'klient_dodanie_nazwisko', value="")
    updateTextInput(session,'klient_dodanie_nr_telefonu', value="")
    updateTextInput(session,'klient_dodanie_nr_dowodu', value="")
    updateTextInput(session,'klient_dodanie_pesel', value="")
    output$klienci_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM klienci ORDER BY id_klienta"))
    shinyalert(print(data[1,1]), type = "info")
  })
  observeEvent(input$zmien_klienta, {
    
    res <- dbSendStatement(con, paste0("select zmien_dane_klienta(",input$klient_zmiana_id_klienta, ",", "'",
                                       input$klient_zmiana_imie,"'", ",", "'",
                                       input$klient_zmiana_nazwisko,"'", ",", "'",
                                       input$klient_zmiana_nr_telefonu,"'", ",", "'",
                                       input$klient_zmiana_nr_dowodu,"'", ",", "'",
                                       input$klient_zmiana_pesel,"'", ",", "'",
                                       input$klient_zmiana_czarna_lista,"'", ")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'klient_zmiana_id_klienta', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_klienta FROM klienci order by 1")), selected = NULL)
    updateTextInput(session,'klient_zmiana_imie', value="")
    updateTextInput(session,'klient_zmiana_nazwisko', value="")
    updateTextInput(session,'klient_zmiana_nr_telefonu', value="")
    updateTextInput(session,'klient_zmiana_nr_dowodu', value="")
    updateTextInput(session,'klient_zmiana_pesel', value="")
    updateSelectInput(session, 'klient_zmiana_czarna_lista', label = NULL, choices =c(FALSE,TRUE), selected = NULL)
    
    output$klienci_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM klienci ORDER BY id_klienta"))
    shinyalert(print(data[1,1]), type = "info")
  })
  


  
  # rejestr
  # wypozycz
  observeEvent(input$wypozycz, {
    
    res <- dbSendStatement(con, paste0("select wypozycz(",input$wypozycz_id_klienta, ",",
                                       input$wypozycz_id_sprzetu, ",", "'",
                                       input$wypozycz_data_zwrotu,"'",")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'wypozycz_id_klienta', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_klienta FROM klienci order by id_klienta")), selected = NULL)
    updateSelectInput(session, 'wypozycz_id_sprzetu', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_sprzetu FROM sprzet WHERE stan_wypozyczenia=FALSE order by id_sprzetu")), selected = NULL)
    updateDateInput(session, 'wypozycz_data_zwrotu', value=NA, min=Sys.Date())
  
    output$rejestr_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM rejestr ORDER BY id_wypozyczenia"))
    shinyalert(print(data[1,1]), type = "info")
  })
  # zwrot
  observeEvent(input$zwrot, {
    
    res <- dbSendStatement(con, paste0("select zwrot(",input$zwrot_id_wypozyczenia,")"))
    data <- dbFetch(res)
    updateSelectInput(session, 'zwrot_id_wypozyczenia', label = NULL, choices =c(" ",dbGetQuery(con, "SELECT id_wypozyczenia FROM rejestr WHERE czy_aktualne=TRUE order by id_wypozyczenia")), selected = NULL)

    output$rejestr_lista <- renderDataTable( dbGetQuery(con, "SELECT * FROM rejestr ORDER BY id_wypozyczenia"))
    shinyalert(print(data[1,1]), type = "info")
  })
})

shinyApp(ui, server, options = list(height = 1080))
