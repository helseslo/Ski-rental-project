/* Usuwanie tabel oraz widoków w celu "wyzerowania bazy"  */
DROP FUNCTION zmien_lokalizacje_sprzetu_id(INTEGER, INTEGER);
DROP FUNCTION zmien_lokalizacje_sprzetu_nazwa(INTEGER, VARCHAR(50));
DROP FUNCTION sumaryczny_przychod_zakres_id(DATE, DATE, INTEGER);
DROP FUNCTION sumaryczny_przychod_zakres_nazwa(DATE, DATE, VARCHAR(50));



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
        RAISE EXCEPTION 'Nie istnieje lokacja o podanym ID!';
    END IF;

    IF NOT czy_sprzet_istnieje THEN
        RAISE EXCEPTION 'Nie istnieje sprzet o podanym ID!';
    END IF;

    IF (id_obecnej_lokacji_sprzetu = id_nowej_lokacji_sprzetu) THEN
        RAISE EXCEPTION 'Sprzet juz jest w danej lokacji!';
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
        RAISE EXCEPTION 'Nie istnieje lokacja o podanej nazwie!';
    END IF;

    IF NOT czy_sprzet_istnieje THEN
        RAISE EXCEPTION 'Nie istnieje sprzet o podanym ID!';
    END IF;

    IF (nazwa_obecnej_lokacji_sprzetu = nazwa_nowej_lokacji_sprzetu) THEN
        RAISE EXCEPTION 'Sprzet juz jest w danej lokacji!';
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
            RAISE EXCEPTION 'Zakres dat jest nieprawidłowy!';
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
        SELECT sum(kara)
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
        RAISE EXCEPTION 'Nie istnieje lokacja o podanym ID!';
    END IF;

    /* Procedura, jeśli został wybrany numer lokacji */
    SELECT sum(rejestr.podstawowy_koszt)
        INTO sumaryczny_przychod_podstawowy
        FROM (rejestr JOIN sprzet USING(id_sprzetu))
        WHERE (rejestr.data_wypozyczenia >= data_od AND rejestr.data_wypozyczenia <= (data_do+1) AND sprzet.id_lokacji=id_lokacji_arg);
    IF (sumaryczny_przychod_podstawowy IS NULL) THEN
        sumaryczny_przychod_podstawowy := 0;
    END IF;
    SELECT sum(rejestr.kara)
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
            RAISE EXCEPTION 'Zakres dat jest nieprawidłowy!';
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
        SELECT sum(kara)
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
        RAISE EXCEPTION 'Nie istnieje lokacja o podanej nazwie!';
    END IF;


    /* Procedura, jeśli została wybrana nazwa lokacji */
    SELECT sum(rejestr.podstawowy_koszt)
        INTO sumaryczny_przychod_podstawowy
        FROM (rejestr JOIN sprzet USING(id_sprzetu))
        WHERE (rejestr.data_wypozyczenia >= data_od AND rejestr.data_wypozyczenia <= (data_do+1) AND sprzet.id_lokacji=id_lokacji_arg);
    IF (sumaryczny_przychod_podstawowy IS NULL) THEN
        sumaryczny_przychod_podstawowy := 0;
    END IF;
    SELECT sum(rejestr.kara)
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

