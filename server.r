##### przydatne linki
# https://shiny.rstudio.com/tutorial/written-tutorial/lesson3/
# http://pbiecek.github.io/Przewodnik/Programowanie/jak_tworzyc_aplikajce.html
# https://rpostgres.r-dbi.org/
# https://datatables.net/reference/option/

##### stworzenie serwera aplikacji shiny
shinyServer(function(input, output) {
  
  # output$lokacje_lista <- 
  #   renderTable( dbGetQuery(con, "SELECT id_lokacji as \"ID\", nazwa_lokacji as \"Nazwa\", miasto as \"Miasto\", ulica as \"Ulica\", nr_posesji as \"Nr posesji\" FROM lokacje"), align = "l", width = "100%")
  # tu definiujemy "output", czyli to, co będzie nam zwracało dane do wyświetlenia na ekranie
  # wybieramy, w jakiej formie ma się to wyświetlić (m.in. tabelki, napisu)
  # jeśli chcemy przekazać do naszej funkcji jakieś argumenty z interfejsu, to używamy odpowiedniego "input"


  output$locations <- renderDataTable(
    load.locations(), # wywołanie funkcji z example_functions.r
    options = list(  # dodatkowe opcje wyglądu tabelki
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  
  output$locations2 <- renderDataTable(
    load.locations2(), # wywołanie funkcji z example_functions.r
    options = list(  # dodatkowe opcje wyglądu tabelki
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )
  
  output$pracownicy <- renderDataTable(
    load.pracownicy(), # wywołanie funkcji z example_functions.r
    options = list(  # dodatkowe opcje wyglądu tabelki
      pageLength = 10,
      lengthChange = FALSE,
      searching = FALSE,
      info = FALSE
    )
  )

  

  output$locations.info <- renderTable(
    load.locations.info(input$nazwa_lokacji) # wywołanie funkcji z example_functions.r
  )
  
  output$pracownicy.info <- renderTable(
    load.pracownicy.info(input$id_pracownika) # wywołanie funkcji z example_functions.r
  )
  
  
  observeEvent(input$upadate.pracownicy,
               zmiana.stanowiska(input$stanowiska.id_stanowiska,
                                    input$pracownicy.id_pracownika)) 
  

  observeEvent(input$refresh, {
    refresh()
  })
  
})
