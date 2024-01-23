library("RPostgres")

##### po��czenie z baz� danych
# gotowa do u�ytku funkcja tworz�ca w R po��czenie z istniej�c� (za�o�on� wcze�niej) baz� danych w PostgreSQL
# nale�y w niej wpisa� swoje w�asne parametry do po��czenia z baz� projektow� (te same, co w konsoli psql)


open.my.connection <- function() {
  con <- dbConnect(RPostgres::Postgres(),
                   dbname = 'projekt', # nazwa naszej projektowej bazy
                   host = 'localhost',
                   port = '5432', # port ten sam co w psql - zwykle 5432
                   user = 'hela', # nasza nazwa u�ytkownika psql
                   password = 'hela') # i nasze has�o tego u�ytkownika
  return (con)
}

# dodatkowa, trywialna funkcja zamykaj�ca po��czenie z baz�
close.my.connection <- function(con) {
  dbDisconnect(con)
}


##### funkcje pomocnicze do obs�ugi bazy danych ze skryptu example_db.sql

# te funkcje b�d� oczywi�cie inne w ka�dym projekcie
# to s� jedynie przyk�ady pokazuj�ce, w jaki spos�b w R mo�emy pisa� polecenia PostgreSQL oraz jak je wykonywa�
# zauwa�my, �e ka�da taka funkcja ma w sobie zaszyte polecenie SQL, kt�re jest wysy�ane na serwer
# niekt�re funkcje przyjmuj� dodatkowe argumenty, kt�re staj� si� elementem wysy�anego polecenia
# a niekt�re funkcje zwracaj� wyniki polecenia SQL (cho� nie wszystkie)

# load.locations <- function() {
#   query = "SELECT * FROM lokacje"
#   con = open.my.connection()
#   res = dbSendQuery(con,query)
#   locations = dbFetch(res)
#   dbClearResult(res)
#   close.my.connection(con)
#   return(locations)
# }

load.locations <- function() {
  query = "SELECT nazwa_lokacji FROM lokacje"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  locations = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(locations)
}

load.locations2 <- function() {
  query = "SELECT id_lokacji FROM lokacje"
  con = open.my.connection()
  res = dbSendQuery(con,query)
  locations = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(locations)
}


load.zmiana.stanowiska <- function(nowe_id_stanowiska, id_pracownika_arg) {
  query = paste0("SELECT zmiana_stanowiska('",
                 nowe_id_stanowiska,"','",id_pracownika_arg,")")
  con = open.my.connection()
  res = dbSendQuery(con,query)
  dbClearResult(res)
  close.my.connection(con)
}

# add.or.update.rating <- function(title,nick,rating) {
#   query = paste0("SELECT add_or_update_rating('",
#                  title,"','",nick,"',",rating,")")
#   con = open.my.connection()
#   res = dbSendQuery(con,query)
#   dbClearResult(res)
#   close.my.connection(con)
# }


# 
# load.movies <- function() {
#   query = "SELECT title FROM movie"
#   con = open.my.connection()
#   res = dbSendQuery(con,query)
#   movies = dbFetch(res)
#   dbClearResult(res)
#   close.my.connection(con)
#   return(movies)add_or_update_rating
# }



load.locations.info <- function(nazwa_lokacji) {
  query = paste0("SELECT id_lokacji, nazwa_lokacji, miasto, ulica, nr_posesji
                FROM lokacje WHERE nazwa_lokacji = '",
                 nazwa_lokacji,"' LIMIT 1")
  con = open.my.connection()
  res = dbSendQuery(con,query)
  locations = dbFetch(res)
  dbClearResult(res)
  close.my.connection(con)
  return(locations)
}

# load.movie.avg.rating <- function(title) {
#   query = paste0("SELECT title, year, average_rating
#                 FROM movie_avg_rating WHERE title = '",
#                  title,"' LIMIT 1")
#   con = open.my.connection()
#   res = dbSendQuery(con,query)
#   rating = dbFetch(res)
#   dbClearResult(res)
#   close.my.connection(con)
#   return(rating$average_rating)
# }
# 
# load.movie.ratings <- function(title) {
#   query = paste0("SELECT title, year, nick, rating
#                 FROM movie_ratings WHERE title = '",
#                  title,"'")
#   con = open.my.connection()
#   res = dbSendQuery(con,query)
#   ratings = dbFetch(res)
#   dbClearResult(res)
#   close.my.connection(con)
#   return(ratings)
# }
# 
# load.login.ratings <- function(nick) {
#   query = paste0("SELECT title, year, nick, rating
#                 FROM movie_ratings WHERE nick = '",
#                  nick,"'")
#   con = open.my.connection()
#   res = dbSendQuery(con,query)
#   ratings = dbFetch(res)
#   dbClearResult(res)
#   close.my.connection(con)
#   return(ratings)
# }

# add.or.update.rating <- function(title,nick,rating) {
#   query = paste0("SELECT add_or_update_rating('",
#                  title,"','",nick,"',",rating,")")
#   con = open.my.connection()
#   res = dbSendQuery(con,query)
#   dbClearResult(res)
#   close.my.connection(con)
# }

# add.login <- function(nick) {
#   if(trimws(nick)!=""){
#     query = paste0("INSERT INTO login(nick) VALUES ('",nick,"')")
#     con = open.my.connection()
#     res = dbSendQuery(con,query)
#     dbClearResult(res)
#     close.my.connection(con)
#   }}



