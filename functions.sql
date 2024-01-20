/* Usuwanie tabel oraz widoków w celu "wyzerowania bazy"  */
DROP FUNCTION zmien_lokalizacje_sprzetu_id(INTEGER, INTEGER);
DROP FUNCTION zmien_lokalizacje_sprzetu_nazwa(INTEGER, VARCHAR(50));



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

