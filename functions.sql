/* FUNKCJE DODAJ */

/* lokacje*/
CREATE OR REPLACE FUNCTION dodaj_lokacje(nazwa_lokacji_arg VARCHAR(50), miasto_arg VARCHAR(50), ulica_arg VARCHAR(50),nr_posesji_arg INTEGER)
RETURNS TEXT AS $$
DECLARE
    czy_lokacja_istnieje BOOLEAN;
BEGIN

    SELECT count(1) > 0 INTO czy_lokacja_istnieje FROM lokacje WHERE nazwa_lokacji = nazwa_lokacji_arg;


	IF czy_lokacja_istnieje THEN
        RETURN 'Istnieje juz lokacja o podanej nazwie!';
    END IF;

	IF nazwa_lokacji_arg IS NULL THEN
		RETURN 'Nazwa lokacji nie moze przyjmowac wartosci NULL!';
	END IF;


    INSERT INTO lokacje (nazwa_lokacji, miasto, ulica, nr_posesji) VALUES 
    (nazwa_lokacji_arg, miasto_arg, ulica_arg, nr_posesji_arg);
    RETURN 'Lokacja dodana poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 


/* stanowiska */
CREATE OR REPLACE FUNCTION dodaj_stanowisko(nazwa_stanowiska_arg VARCHAR(50))
RETURNS TEXT AS $$
DECLARE
    czy_stanowisko_istnieje BOOLEAN;
BEGIN

    SELECT count(1) > 0 INTO czy_stanowisko_istnieje FROM stanowiska WHERE nazwa_stanowiska = nazwa_stanowiska_arg;


	IF czy_stanowisko_istnieje THEN
        	return 'Istnieje juz stanowisko o podanej nazwie!';
   	 END IF;


    INSERT INTO stanowiska (nazwa_stanowiska) VALUES 
    (nazwa_stanowiska_arg);
    RETURN 'Stanowisko dodane poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 


/* pracownicy */
CREATE OR REPLACE FUNCTION dodaj_pracownika(imie_arg VARCHAR(50), nazwisko_arg VARCHAR(50), 
                                      id_lokacji_arg INTEGER, id_stanowiska_arg INTEGER)
RETURNS TEXT AS $$
DECLARE
	czy_istnieje_lokacja BOOLEAN;
    	czy_istnieje_stanowisko BOOLEAN;
BEGIN

	SELECT count(1) > 0 INTO czy_istnieje_lokacja FROM lokacje WHERE id_lokacji = id_lokacji_arg;
	SELECT count(1) > 0 INTO czy_istnieje_stanowisko FROM stanowiska WHERE id_stanowiska = id_stanowiska_arg;


	if not czy_istnieje_lokacja THEN
    		return 'Nie istnieje lokacja o podanym ID!';
    	end if;

	if not czy_istnieje_stanowisko THEN
    		return 'Nie istnieje stanowisko o podanym ID!';
    	end if;


    	INSERT INTO pracownicy (imie, nazwisko, id_lokacji, id_stanowiska) VALUES 
    	(imie_arg, nazwisko_arg, id_lokacji_arg, id_stanowiska_arg);
    	RETURN 'Pracownik dodany poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 


/* kategorie */
create or replace function dodaj_kategorie(nazwa_kategorii_arg VARCHAR(50)) 
returns text as $$
DECLARE
	czy_istnieje_kategoria BOOLEAN;
BEGIN

	SELECT count(1) > 0 INTO czy_istnieje_kategoria FROM kategorie WHERE nazwa_kategorii = nazwa_kategorii_arg;
    
    IF czy_istnieje_kategoria THEN
        RETURN 'Istnieje kategoria o podanej nazwie!';
    END IF;


    INSERT INTO kategorie (nazwa_kategorii) VALUES 
    (nazwa_kategorii_arg);
    RETURN 'Kategoria dodana poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 



/* sprzęt */
create or replace function dodaj_sprzet(id_kategorii_arg INTEGER, rozmiar_arg INTEGER, firma_arg VARCHAR(50),
                                       id_lokacji_arg INTEGER) 
returns text as $$
DECLARE
	czy_istnieje_kategoria BOOLEAN;
    	czy_istnieje_lokacja BOOLEAN;
BEGIN

	SELECT count(1) > 0 INTO czy_istnieje_kategoria FROM kategorie WHERE id_kategorii = id_kategorii_arg;
    	SELECT count(1) > 0 INTO czy_istnieje_lokacja FROM lokacje WHERE id_lokacji = id_lokacji_arg;
    
    IF not czy_istnieje_kategoria THEN
        RETURN 'Nie istnieje kategoria o podanym ID!';
    END IF;

    IF not czy_istnieje_lokacja THEN
        RETURN 'Nie istnieje lokacja o podanym ID!';
    END IF;
    
    if rozmiar_arg IS NULL THEN
    	RETURN 'Rozmiar nie moze przyjmowac wartosci NULL!';
    END IF;

    INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES 
    (id_kategorii_arg, rozmiar_arg, firma_arg, id_lokacji_arg);
    RETURN 'Sprzęt dodany poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 


/* cennik */
CREATE OR REPLACE FUNCTION dodaj_cene(cena_arg DECIMAL(7,2), kara_arg DECIMAL(7,2), 
					id_lokacji_arg INTEGER, id_kategorii_arg INTEGER)
RETURNS TEXT AS $$
DECLARE
    czy_lokacja_istnieje BOOLEAN;
    czy_kategoria_istnieje BOOLEAN;
    czy_cena_istnieje BOOLEAN;
BEGIN

    SELECT count(1) > 0 INTO czy_lokacja_istnieje FROM lokacje WHERE id_lokacji = id_lokacji_arg;
    SELECT count(1) > 0 INTO czy_kategoria_istnieje FROM kategorie WHERE id_kategorii = id_kategorii_arg;
    SELECT count(1) > 0 INTO czy_cena_istnieje FROM cennik 
    WHERE id_kategorii = id_kategorii_arg and id_lokacji = id_lokacji_arg;


	IF not czy_lokacja_istnieje THEN
        RETURN 'Nie istnieje lokacja o podanym ID!';
    END IF;
    
    IF not czy_kategoria_istnieje THEN
        RETURN 'Nie istnieje kategoria o podanym ID!';
    END IF;
    
    if czy_cena_istnieje THEN
    	return 'Istnieje juz cena dla podanej kategorii i lokacji.';
    end if;
    
    /* sprawdzmy, czy uzytkownik wpisał null */
    if (cena_arg IS NULL or kara_arg IS NULL) THEN
    	return 'Cena i kara musza przyjmowac wartosci inne niz null!';
    end if;


    INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES 
    (cena_arg, kara_arg, id_lokacji_arg, id_kategorii_arg);
    RETURN 'Cena dodana poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 



/* klienci */
CREATE OR REPLACE FUNCTION dodaj_klienta(imie_arg VARCHAR(50), nazwisko_arg VARCHAR(50), 
                 nr_telefonu_arg VARCHAR(9),nr_dowodu_arg VARCHAR(8), pesel_arg VARCHAR(11))
RETURNS TEXT AS $$
DECLARE
	czy_istnieje_nr_telefonu BOOLEAN;
    	czy_istnieje_nr_dowodu BOOLEAN;
    	czy_istnieje_pesel BOOLEAN;
BEGIN

	SELECT count(1) > 0 INTO czy_istnieje_nr_telefonu FROM klienci WHERE nr_telefonu = nr_telefonu_arg;
	SELECT count(1) > 0 INTO czy_istnieje_nr_dowodu FROM klienci WHERE nr_dowodu = nr_dowodu_arg;
    	SELECT count(1) > 0 INTO czy_istnieje_pesel FROM klienci WHERE pesel = pesel_arg;


	if czy_istnieje_nr_telefonu THEN
    		return 'W bazie istnieje juz klient o takim nr telefonu!';
   	 end if;

	if czy_istnieje_nr_dowodu THEN
    		return 'W bazie istnieje juz klient o takim nr dowodu!';
    	end if;

	IF czy_istnieje_pesel THEN
        	RETURN 'W bazie istnieje juz klient o takim numerze pesel!';
   	 END IF;


    	INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, pesel) VALUES 
    	(imie_arg, nazwisko_arg, nr_telefonu_arg, nr_dowodu_arg, pesel_arg);
    	RETURN 'Klient dodany poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 




/* dodaj rejestr */
create or replace function wypozycz (id_klienta_arg INTEGER, id_sprzetu_arg INTEGER,
                                    data_zwrotu_arg DATE)
returns text AS $$
DECLARE
		czy_istnieje_klient BOOLEAN;
    	czy_istnieje_sprzet BOOLEAN;
    	czy_sprzet_jest_dostepny BOOLEAN;
        czy_klient_na_czarnej_liscie BOOLEAN;
        koszt INTEGER;
        kategoria_sprzetu INTEGER;
        lokacja_sprzetu INTEGER;

BEGIN
	
    
    SELECT count(1) > 0 INTO czy_istnieje_klient FROM klienci WHERE id_klienta = id_klienta_arg;
    select count(1) > 0 into czy_istnieje_sprzet from sprzet where id_sprzetu = id_sprzetu_arg;
    select count(1) > 0 into czy_sprzet_jest_dostepny from sprzet where id_sprzetu = id_sprzetu_arg 
    								and stan_wypozyczenia = 'f';
    select count(1) > 0 into czy_klient_na_czarnej_liscie from klienci where id_klienta = id_klienta_arg
    								and czarna_lista = 't';
    select id_kategorii into kategoria_sprzetu from sprzet where id_sprzetu = id_sprzetu_arg;
    select id_lokacji into lokacja_sprzetu from sprzet where id_sprzetu = id_sprzetu_arg;
    select cena*(data_zwrotu_arg - current_date + 1) into koszt from cennik 
    where id_kategorii = kategoria_sprzetu and id_lokacji = lokacja_sprzetu;
    
     if not czy_istnieje_klient THEN
    	RETURN 'W bazie nie istnieje klient o podanym ID !';
    END IF;
    
    if not czy_istnieje_sprzet THEN
    	RETURN 'W bazie nie istnieje sprzet o podanym ID !';
    END IF;
    
    if not czy_sprzet_jest_dostepny THEN
    	return 'Sprzet o podanym ID jest juz wypozyczony!';
    end if;
    
    if czy_klient_na_czarnej_liscie THEN
    	return 'Klient jest na czarnej liscie - nie moze wypozyczyc sprzetu.';
    end if;
    
    if (data_zwrotu_arg < (SELECT CURRENT_DATE)) THEN
    	return 'Data zwrotu nie moze byc wczesniejsza niz obecna data!';
    end if;

    
   	/* po sprawdzeniu potrzebnych warunków dodajemy rejestr do tabeli */
    insert into rejestr(id_klienta, id_sprzetu, data_zwrotu, maksymalne_przedluzenie, podstawowy_koszt, czy_aktualne)
    values (id_klienta_arg, id_sprzetu_arg, data_zwrotu_arg, data_zwrotu_arg + 7, koszt, 't');
   
    
    /* w tabeli sprzęt musimy zmienić atrybut 'stan_wypozyczenia' dla sprzętu, który został wypozyczony */
    update sprzet set stan_wypozyczenia = 't'
    where id_sprzetu = id_sprzetu_arg;

    return 'Wypozyczenie dodane poprawnie!';
    
 end;
 $$ LANGUAGE 'plpgsql';




/* Funkcja sluzaca do zmiany lokacji sprzetu; uzywana w przypadku, gdy chcemy przeniesc konkrenty sprzet do innej lokalizacji.
W tej wersji jako argument podajemy id sprzetu, ktorego lokacje chcemy zmienic oraz id tej lokacji.*/

CREATE OR REPLACE FUNCTION zmien_lokalizacje_sprzetu_id(id_sprzetu_arg INTEGER, id_nowej_lokacji_sprzetu INTEGER)
RETURNS TEXT AS $$
DECLARE
    czy_lokacja_istnieje BOOLEAN;
    czy_sprzet_istnieje BOOLEAN;
    id_obecnej_lokacji_sprzetu INTEGER;
BEGIN

    /*Przypisujemy prawda/fałsz do zmiennej odpowiadającej na pytanie, czy podane id lokacji istnieje w tabeli.
    Analogicznie robimy dla zmiennej dotyczącej sprzętu. Natomiast do id_obecnej_lokacji_sprzetu przypisujemy id_lokacji.*/
    SELECT count(1) > 0 INTO czy_lokacja_istnieje FROM lokacje WHERE id_lokacji = id_nowej_lokacji_sprzetu;
    SELECT count(1) > 0 INTO czy_sprzet_istnieje FROM sprzet WHERE id_sprzetu = id_sprzetu_arg;
    SELECT id_lokacji INTO id_obecnej_lokacji_sprzetu FROM sprzet WHERE id_sprzetu = id_sprzetu_arg;

	IF NOT czy_lokacja_istnieje THEN
        return 'Nie istnieje lokacja o podanym ID!';
    END IF;

    IF NOT czy_sprzet_istnieje THEN
        return 'Nie istnieje sprzet o podanym ID!';
    END IF;

    IF (id_obecnej_lokacji_sprzetu = id_nowej_lokacji_sprzetu) THEN
        return 'Sprzet juz jest w danej lokacji!';
    END IF;

    UPDATE sprzet SET id_lokacji=id_nowej_lokacji_sprzetu WHERE id_sprzetu=id_sprzetu_arg;
    RETURN 'Lokacja zmieniona poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 

/* wyzwalacz blokujący dodanie nart jako wypozyczonych */
/* wyzwalacz - nie moze byc 2 takich samych cen dla jednej lokacji i kategorii!!!!*/




/* Funkcja sluzaca do zmiany lokacji sprzetu; uzywana w przypadku, gdy chcemy przeniesc konkrenty sprzet do innej lokalizacji.
W tej wersji jako argument podajemy id sprzetu, ktorego lokacje chcemy zmienic oraz nazwe tej lokacji.*/

CREATE OR REPLACE FUNCTION zmien_lokalizacje_sprzetu_nazwa(id_sprzetu_arg INTEGER, nazwa_nowej_lokacji_sprzetu VARCHAR(50))
RETURNS TEXT AS $$
DECLARE
    czy_lokacja_istnieje BOOLEAN;
    czy_sprzet_istnieje BOOLEAN;
    nazwa_obecnej_lokacji_sprzetu VARCHAR(50);
    id_nowej_lokacji_sprzetu INTEGER;
BEGIN

    /*Przypisujemy prawda/fałsz do zmiennej odpowiadającej na pytanie, czy podana nazwa lokacji istnieje w tabeli.
    Analogicznie robimy dla zmiennej id dotyczącej sprzętu. Natomiast do nazwa_obecnej_lokacji_sprzetu przypisujemy nazwa_lokacji.*/
    SELECT count(1) > 0 INTO czy_lokacja_istnieje FROM lokacje WHERE nazwa_lokacji = nazwa_nowej_lokacji_sprzetu;
    SELECT count(1) > 0 INTO czy_sprzet_istnieje FROM sprzet WHERE id_sprzetu = id_sprzetu_arg;
    SELECT lokacje.nazwa_lokacji INTO nazwa_obecnej_lokacji_sprzetu FROM (sprzet JOIN lokacje USING(id_lokacji))
        WHERE id_sprzetu = id_sprzetu_arg;

	IF NOT czy_lokacja_istnieje THEN
        RETURN 'Nie istnieje lokacja o podanej nazwie!';
    END IF;

    IF NOT czy_sprzet_istnieje THEN
        RETURN 'Nie istnieje sprzet o podanym ID!';
    END IF;

    IF (nazwa_obecnej_lokacji_sprzetu = nazwa_nowej_lokacji_sprzetu) THEN
        RETURN 'Sprzet juz jest w danej lokacji!';
    END IF;

    SELECT id_lokacji INTO id_nowej_lokacji_sprzetu FROM lokacje WHERE nazwa_lokacji=nazwa_nowej_lokacji_sprzetu;

    UPDATE sprzet SET id_lokacji=id_nowej_lokacji_sprzetu WHERE id_sprzetu=id_sprzetu_arg;
    RETURN 'Lokacja zmieniona poprawnie!';
END;
$$ LANGUAGE 'plpgsql'; 



/* Funkcja wyliczająca sumaryczny przychód; (w podanym zakresie dat, dla podanej lokacji - opcjonalnie)*/
CREATE OR REPLACE FUNCTION sumaryczny_przychod_zakres_id(data_od DATE, data_do DATE, id_lokacji_arg INTEGER DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
    sumaryczny_przychod_podstawowy DECIMAL(7, 2);
    sumaryczny_przychod_kary DECIMAL(7, 2);
    sumaryczny_przychod DECIMAL(7, 2);
    czy_lokacja_istnieje BOOLEAN;
BEGIN

    /* Najpierw sprawdzamy, czy zostały wybrane prawidłowe daty*/
    IF (data_od > data_do) THEN
            RETURN 'Zakres dat jest nieprawidłowy!';
    END IF;

    /* Procedura, jeśli nie został wybrany numer lokacji */
    IF (id_lokacji_arg IS NULL) THEN
        SELECT sum(podstawowy_koszt)
            INTO sumaryczny_przychod_podstawowy
            FROM rejestr
            WHERE (data_wypozyczenia >= data_od AND data_wypozyczenia <= (data_do+1));
        IF (sumaryczny_przychod_podstawowy IS NULL) THEN
            sumaryczny_przychod_podstawowy := 0;
        END IF;
        SELECT sum(naliczona_kara)
            INTO sumaryczny_przychod_kary
            FROM rejestr
            WHERE (data_zwrotu >= data_od AND data_zwrotu <= (data_do+1)); 
        IF (sumaryczny_przychod_kary IS NULL) THEN
            sumaryczny_przychod_kary := 0;
        END IF;
        sumaryczny_przychod := sumaryczny_przychod_podstawowy+sumaryczny_przychod_kary;
        RETURN ('Sumaryczny przychód za ten okres to: ' || sumaryczny_przychod || ' zł.');
    END IF;

    SELECT count(1) > 0 INTO czy_lokacja_istnieje FROM lokacje WHERE id_lokacji = id_lokacji_arg;

    IF NOT czy_lokacja_istnieje THEN
        RETURN 'Nie istnieje lokacja o podanym ID!';
    END IF;

    /* Procedura, jeśli został wybrany numer lokacji */
    SELECT sum(rejestr.podstawowy_koszt)
        INTO sumaryczny_przychod_podstawowy
        FROM (rejestr JOIN sprzet USING(id_sprzetu))
        WHERE (rejestr.data_wypozyczenia >= data_od AND rejestr.data_wypozyczenia <= (data_do+1) AND sprzet.id_lokacji=id_lokacji_arg);
    IF (sumaryczny_przychod_podstawowy IS NULL) THEN
        sumaryczny_przychod_podstawowy := 0;
    END IF;
    SELECT sum(rejestr.naliczona_kara)
        INTO sumaryczny_przychod_kary
        FROM (rejestr JOIN sprzet USING(id_sprzetu))
        WHERE (rejestr.data_zwrotu >= data_od AND rejestr.data_zwrotu <= (data_do+1) AND sprzet.id_lokacji=id_lokacji_arg);
    IF (sumaryczny_przychod_kary IS NULL) THEN
        sumaryczny_przychod_kary := 0;
    END IF;

    sumaryczny_przychod := sumaryczny_przychod_podstawowy+sumaryczny_przychod_kary;
    RETURN ('Sumaryczny przychód za ten okres dla lokacji numer ' || id_lokacji_arg || ' to: ' || sumaryczny_przychod || ' zł.');


END;
$$ LANGUAGE 'plpgsql'; 





/* Funkcja wyliczająca sumaryczny przychód; (w podanym zakresie dat, dla podanej nazwy lokacji - opcjonalnie)*/
CREATE OR REPLACE FUNCTION sumaryczny_przychod_zakres_nazwa(data_od DATE, data_do DATE, nazwa_lokacji_arg VARCHAR(50) DEFAULT NULL)
RETURNS TEXT AS $$
DECLARE
    sumaryczny_przychod_podstawowy DECIMAL(7, 2);
    sumaryczny_przychod_kary DECIMAL(7, 2);
    sumaryczny_przychod DECIMAL(7, 2);
    czy_lokacja_istnieje BOOLEAN;
    id_lokacji_arg INTEGER;
BEGIN

    /* Najpierw sprawdzamy, czy zostały wybrane prawidłowe daty*/
    IF (data_od > data_do) THEN
            RETURN 'Zakres dat jest nieprawidłowy!';
    END IF;

    /* Procedura, jeśli nie została wybrana nazwa lokacji */
    IF (nazwa_lokacji_arg IS NULL) THEN
        SELECT sum(podstawowy_koszt)
            INTO sumaryczny_przychod_podstawowy
            FROM rejestr
            WHERE (data_wypozyczenia >= data_od AND data_wypozyczenia <= (data_do+1));
        IF (sumaryczny_przychod_podstawowy IS NULL) THEN
            sumaryczny_przychod_podstawowy := 0;
        END IF;
        SELECT sum(naliczona_kara)
            INTO sumaryczny_przychod_kary
            FROM rejestr
            WHERE (data_zwrotu >= data_od AND data_zwrotu <= (data_do+1)); 
        IF (sumaryczny_przychod_kary IS NULL) THEN
            sumaryczny_przychod_kary := 0;
        END IF;
        sumaryczny_przychod := sumaryczny_przychod_podstawowy+sumaryczny_przychod_kary;
        RETURN ('Sumaryczny przychód za ten okres to: ' || sumaryczny_przychod || ' zł.');
    END IF;

    SELECT id_lokacji INTO id_lokacji_arg FROM lokacje WHERE nazwa_lokacji = nazwa_lokacji_arg;

    IF id_lokacji_arg IS NULL THEN
        RETURN 'Nie istnieje lokacja o podanej nazwie!';
    END IF;


    /* Procedura, jeśli została wybrana nazwa lokacji */
    SELECT sum(rejestr.podstawowy_koszt)
        INTO sumaryczny_przychod_podstawowy
        FROM (rejestr JOIN sprzet USING(id_sprzetu))
        WHERE (rejestr.data_wypozyczenia >= data_od AND rejestr.data_wypozyczenia <= (data_do+1) AND sprzet.id_lokacji=id_lokacji_arg);
    IF (sumaryczny_przychod_podstawowy IS NULL) THEN
        sumaryczny_przychod_podstawowy := 0;
    END IF;
    SELECT sum(rejestr.naliczona_kara)
        INTO sumaryczny_przychod_kary
        FROM (rejestr JOIN sprzet USING(id_sprzetu))
        WHERE (rejestr.data_zwrotu >= data_od AND rejestr.data_zwrotu <= (data_do+1) AND sprzet.id_lokacji=id_lokacji_arg);
    IF (sumaryczny_przychod_kary IS NULL) THEN
        sumaryczny_przychod_kary := 0;
    END IF;

    sumaryczny_przychod := sumaryczny_przychod_podstawowy+sumaryczny_przychod_kary;
    RETURN ('Sumaryczny przychód za ten okres dla lokacji ' || nazwa_lokacji_arg || ' to: ' || sumaryczny_przychod || ' zł.');


END;
$$ LANGUAGE 'plpgsql'; 




/* Widok top lokacje */
create OR REPLACE view top_lokacje as
select sprzet.id_lokacji as id_lokacji, count(id_wypozyczenia) as ilosc_wypozyczen
from rejestr join sprzet using (id_sprzetu)
group by sprzet.id_lokacji
order by sprzet.id_lokacji;

/*Widok top sprzęt*/
create  OR REPLACE view top_sprzet as
select sprzet.id_sprzetu as id_sprzetu, sprzet.id_lokacji as id_lokacji, count(id_wypozyczenia) as ilosc_wypozyczen
from rejestr join sprzet using (id_sprzetu)
group by sprzet.id_sprzetu
order by ilosc_wypozyczen DESC, sprzet.id_sprzetu;




/* Funkcja zmieniająca cenę i karę w cenniku dla podanej lokacji i kategorii */
create or replace function zmien_cennik (nowa_cena DECIMAL(7,2), nowa_naliczona_kara DECIMAL(7,2),
                                         moje_id_lokacji INTEGER, moje_id_kategorii INTEGER)
returns TEXT as $$
DECLARE
    czy_istnieje_cena boolean;
    czy_istnieje_lokacja boolean;
    czy_istnieje_kategoria boolean;
BEGIN

	select count(1) > 0 into czy_istnieje_lokacja from lokacje where id_lokacji = moje_id_lokacji;
    select count(1) > 0 into czy_istnieje_kategoria from kategorie where id_kategorii = moje_id_kategorii;
	SELECT count(1) > 0 INTO czy_istnieje_cena FROM cennik WHERE id_kategorii = moje_id_kategorii 
    								and id_lokacji = moje_id_lokacji;
                                                            
    if not czy_istnieje_lokacja THEN
    	return 'Nie istnieje lokacja o podanym ID :(';
    END IF;
    
    if not czy_istnieje_kategoria THEN
    	return 'Nie istnieje kategoria o podanym ID :(';
    END IF;
    
    /* Istnieje taka lokacja i kategoria, ale nie ma przypisanej ceny w cenniku dla tej lokacji i kategorii */
    IF NOT czy_istnieje_cena THEN
        return 'W cenniku nie ma ceny dla podanej lokacji i kategorii. Najpierw dodaj cenę do cennika.';
    END IF;
    
    if (nowa_cena is null or nowa_naliczona_kara is null) THEN
    	return 'Cena i kara nie moga przyjmowac wartosci NULL!';
    end if;
    
    update cennik set cena = nowa_cena
    where id_lokacji = moje_id_lokacji AND id_kategorii = moje_id_kategorii;
    
    update cennik set naliczona_kara = nowa_naliczona_kara
    where id_lokacji = moje_id_lokacji AND id_kategorii = moje_id_kategorii;
    
    return 'Cennik zmieniony poprawnie!';
    
 end;
 $$ LANGUAGE 'plpgsql';




/* Funkcja zmieniająca cenę o podany procent w cenniku dla podanej lokacji i kategorii */
create or replace function zmien_cennik_o_procent (procent_ceny DECIMAL(7, 3), procent_kary DECIMAL(7,3), 
                                                   moje_id_lokacji INTEGER, moje_id_kategorii INTEGER)
RETURNS TEXT AS $$
DECLARE
	czy_istnieje_cena boolean;
    	czy_istnieje_lokacja boolean;
    	czy_istnieje_kategoria boolean;
BEGIN

	select count(1) > 0 into czy_istnieje_lokacja from lokacje where id_lokacji = moje_id_lokacji;
    	select count(1) > 0 into czy_istnieje_kategoria from kategorie where id_kategorii = moje_id_kategorii;
	SELECT count(1) > 0 INTO czy_istnieje_cena FROM cennik WHERE id_kategorii = moje_id_kategorii 
    								and id_lokacji = moje_id_lokacji;
                                    
    if procent_ceny < -1 or procent_kary < -1 then
    	RETURN 'Nie można obniżyć ceny o więcej niż 100 procent!' ;
    end if;
                                                            
    if not czy_istnieje_lokacja THEN
    	RETURN 'Nie istnieje lokacja o podanym ID :(';
    END IF;
    
    if not czy_istnieje_kategoria THEN
    	RETURN 'Nie istnieje kategoria o podanym ID :(';
    END IF;
    
    if not czy_istnieje_cena THEN
    	RETURN 'W cenniku nie ma podanej ceny dla wybranej lokacji i kategorii.
        Najpierw dodaj cenę do cennika.';
    END IF;
    
    
    update cennik set cena = (1 + procent_ceny)*cena
    where id_lokacji = moje_id_lokacji AND id_kategorii = moje_id_kategorii;
    
    update cennik set naliczona_kara = (1 + procent_kary)*naliczona_kara
    where id_lokacji = moje_id_lokacji AND id_kategorii = moje_id_kategorii;
    
    return 'Cennik zmieniony poprawnie!';
    
 end;
 $$ LANGUAGE 'plpgsql';




/* Funkcja zmieniająca stanowisko pracownika o podanym id */
create or replace function zmiana_stanowiska (nowe_id_stanowiska INTEGER, moje_id_pracownika INTEGER)
returns TEXT as $$
DECLARE
	czy_istnieje_stanowisko BOOLEAN;
    czy_istnieje_pracownik BOOLEAN;
BEGIN
	SELECT count(1) > 0 INTO czy_istnieje_stanowisko FROM pracownicy WHERE id_stanowiska = nowe_id_stanowiska;
    SELECT count(1) > 0 INTO czy_istnieje_pracownik FROM pracownicy WHERE id_pracownika = moje_id_pracownika;
    
    IF NOT czy_istnieje_stanowisko THEN
        RETURN 'Nie istnieje stanowisko o podanym ID :(';
    END IF;

    IF NOT czy_istnieje_pracownik THEN
        RETURN 'Nie istnieje pracownik o podanym ID :(';
    END IF;
    
    update pracownicy set id_stanowiska = nowe_id_stanowiska 
    where id_pracownika = moje_id_pracownika;
    
    return 'Stanowisko zmieniono poprawnie!';
    
 end;
 $$ LANGUAGE 'plpgsql';





 /* Funkcja zwracająca pracowników dla podanej lokacji; zamiast id_stanowiska wyświetlana będzie jego nazwa*/
/* W razie podania lokacji, która nie istnieje, będziemy zwracać pustą tabelę*/

/*CREATE OR REPLACE FUNCTION pracownicy_dla_lokacji (id_lokacji_arg INTEGER, OUT id_pracownika INTEGER, OUT imie VARCHAR(50),
OUT nazwisko VARCHAR(50), OUT nazwa_stanowiska VARCHAR(50))
RETURNS SETOF record 
AS $$
    SELECT pracownicy.id_pracownika, pracownicy.imie, pracownicy.nazwisko, stanowiska.nazwa_stanowiska
    FROM (pracownicy JOIN stanowiska USING (id_stanowiska))
    WHERE id_lokacji=id_lokacji_arg;
$$ LANGUAGE SQL;*/

/*CREATE OR REPLACE FUNCTION pracownicy_dla_lokacji(id_lokacji_arg INTEGER)
  RETURNS SETOF record
  LANGUAGE plpgsql AS
$func$
BEGIN
   RETURN QUERY EXECUTE format('
      SELECT pracownicy.id_pracownika, pracownicy.imie, pracownicy.nazwisko, stanowiska.nazwa_stanowiska
    FROM (pracownicy JOIN stanowiska USING (id_stanowiska))
    WHERE id_lokacji='||_id||'');

END;
$func$;*/




/* Funkcja zmieniająca dane klienta */
 create or replace function zmien_dane_klienta(moje_id_klienta INTEGER, nowe_imie VARCHAR(50),
                                                nowe_nazwisko VARCHAR(50), nowy_nr_telefonu VARCHAR(9),
                           			nowy_nr_dowodu VARCHAR(8), nowy_pesel VARCHAR(11),
                            			nowa_czarna_lista BOOLEAN)
 returns TEXT AS $$
 Declare
 	czy_istnieje_klient boolean;
    
 BEGIN
 
 	SELECT count(1) > 0 INTO czy_istnieje_klient FROM klienci WHERE id_klienta = moje_id_klienta;
    
    IF NOT czy_istnieje_klient THEN
        RETURN 'W bazie nie istnieje klient o podanym ID.';
    END IF;
    
   update klienci
   set  imie = nowe_imie
   where id_klienta = moje_id_klienta;
   
   update klienci
   set  nazwisko = nowe_nazwisko
   where id_klienta = moje_id_klienta;
   
   update klienci
   set  nr_telefonu = nowy_nr_telefonu
   where id_klienta = moje_id_klienta;
   
   update klienci
   set  nr_dowodu = nowy_nr_dowodu
   where id_klienta = moje_id_klienta;
   
   update klienci
   set  pesel = nowy_pesel
   where id_klienta = moje_id_klienta;
   
   update klienci
   set  czarna_lista = nowa_czarna_lista
   where id_klienta = moje_id_klienta;
   
   return 'Zmieniono poprawnie!';
  end;
  $$ LANGUAGE 'plpgsql';




/* Funkcja zmieniająca dane pracownika; analogiczna do tej dla klienta */
create or replace function zmien_dane_pracownika(moje_id_pracownika INTEGER, nowe_imie VARCHAR(50),
                                                nowe_nazwisko VARCHAR(50), nowe_id_lokacji INTEGER,
                           			nowe_id_stanowiska INTEGER)
 returns TEXT AS $$
 DEclare
 	czy_istnieje_pracownik boolean;
    
 BEGIN
 
 	SELECT count(1) > 0 INTO czy_istnieje_pracownik FROM pracownicy WHERE id_pracownika = moje_id_pracownika;
    
    IF NOT czy_istnieje_pracownik THEN
        RETURN 'W bazie nie istnieje pracownik o podanym ID.';
    END IF;
    
   update pracownicy
   set  imie = nowe_imie
   where id_pracownika = moje_id_pracownika;
   
   update pracownicy
   set  nazwisko = nowe_nazwisko
   where id_pracownika = moje_id_pracownika;
   
   update pracownicy
   set  id_lokacji = nowe_id_lokacji
   where id_pracownika = moje_id_pracownika;
   
   update pracownicy
   set  id_stanowiska = nowe_id_stanowiska
   where id_pracownika = moje_id_pracownika;
   
   
   return 'Zmieniono poprawnie!';
  end;
  $$ LANGUAGE 'plpgsql';
  



/* funkcja do zwracania sprzętu */
create or replace function zwrot (moje_id_wypozyczenia INTEGER)
returns text AS $$
DECLARE
	czy_istnieje_wypozyczenie BOOLEAN;
    	czy_jeszcze_nieoddane BOOLEAN;
    	nr_sprzetu INTEGER;
        wielkosc_kary_za_dzien INTEGER;
        obecna_data DATE;
        czy_przekroczono_max_przedl BOOLEAN;
        ile_po_terminie integer;

BEGIN
	
    /* czy_jeszcze_nieoddane zapobiega zaktualizowaniu daty oddania w przypadku wypożyczenia, które jest już nieaktualne */
	SELECT count(1) > 0 INTO czy_istnieje_wypozyczenie FROM rejestr WHERE id_wypozyczenia = moje_id_wypozyczenia;
    select count(1) > 0 into czy_jeszcze_nieoddane from rejestr 
	    where id_wypozyczenia = moje_id_wypozyczenia and czy_aktualne = 't';
    select id_sprzetu into nr_sprzetu from rejestr where id_wypozyczenia = moje_id_wypozyczenia;
    select cennik.kara into wielkosc_kary_za_dzien from cennik join sprzet using(id_kategorii, id_lokacji)
    	where sprzet.id_sprzetu = nr_sprzetu;
    select CURRENT_date into obecna_data;
    select current_date - data_zwrotu::DATE into ile_po_terminie from rejestr where id_wypozyczenia = moje_id_wypozyczenia;
    
     if not czy_istnieje_wypozyczenie THEN
    	RETURN 'W bazie nie istnieje wypozyczenie o podanym ID !';
    END IF;
    
    if not czy_jeszcze_nieoddane THEN
    	RETURN 'Dla wypozyczenia o podanym ID zwrot juz zostal dokonany.';
    END IF; 

    if ile_po_terminie > 7 THEN
    	update klienci set czarna_lista = 't' 
        where id_klienta = (select id_klienta from rejestr where id_wypozyczenia = moje_id_wypozyczenia);
     end if;
    
    /* jeżeli oddano po terminie, naliczamy karę */
    update rejestr set naliczona_kara = wielkosc_kary_za_dzien * ile_po_terminie
    where id_wypozyczenia = moje_id_wypozyczenia and data_zwrotu < obecna_data;
    
    /* zmieniamy date zwrotu na date obecną */
    update rejestr set data_zwrotu = obecna_data
    WHERE id_wypozyczenia = moje_id_wypozyczenia;
    
    /* musimy zmienic atrybut czy_aktualne */
    update rejestr set czy_aktualne = 'f'
    where id_wypozyczenia = moje_id_wypozyczenia;
   
    
    /* w tabeli sprzęt musimy zmienić atrybut 'stan_wypozyczenia' dla sprzętu, który został oddany */
    update sprzet set stan_wypozyczenia = 'f'
    where id_sprzetu = nr_sprzetu;

    return 'Zwrot dodany poprawnie!';
    
 end;
 $$ LANGUAGE 'plpgsql';




/* WYZWALACZE */
