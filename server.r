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

  # generowanie tabelki z ratingami dla zadanego tytułu filmu
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
  
  # generowanie napisu ze średnim ratingiem wybranego filmu
  output$locations.info <- renderTable(
    load.locations.info(input$nazwa_lokacji) # wywołanie funkcji z example_functions.r
  )
  
  # output$zmiana.stanowiska <- renderText(
  #   nowe_id_stanowiska <- reactive(input$nowe_id_stanowiska),
  #   id_pracownika_arg <- reactive(input$id_pracownika_arg),
  #   load.zmiana.stanowiska(nowe_id_stanowiska(), id_pracownika_arg()) # wywołanie funkcji z example_functions.r
  # )
  
  observeEvent(input$upadate.pracownicy,
               zmiana.stanowiska(input$stanowiska.id_stanowiska,
                                    input$pracownicy.id_pracownika)) 
  
  observeEvent(input$update.pracownicy,
               update.pracownicy(input$pracownicy.to.update))
  # 
  # generowanie tabelki z ratingami podanego użytkownika
  # output$login.ratings <- renderDataTable(
  #   load.login.ratings(input$login), # wywołanie funkcji z example_functions.r
  #   options = list(
  #     pageLength = 10,
  #     lengthChange = FALSE,
  #     searching = FALSE,
  #     info = FALSE
  #   )
  # )
  
  # dzięki temu po kliknięciu przycisku aktualizacji ratingu, ta aktualizacja trafi do bazy danych
  # observeEvent(input$load.lokacje,
  #              add.or.update.lokacje(input$lokacje.nazwa_lokacji,
  #                                   input$lokacje.miasto,
  #                                   input$lokacje.ulica,
  #                                   input$lokacje.nr_posesji,
  #                                   input$lokacje))  # ywołanie funkcji z example_functions.r
  
  # a dzięki temu po kliknięciu przycisku będzie działało dodawanie użytkowników do bazy
  # observeEvent(input$locations,
  #              add.login(input$login.to.add))  # wywołanie funkcji z example_functions.r
  
  # i obsługa przycisku odświeżania aplikacji
  observeEvent(input$refresh, {
    refresh()
  })
  
})
