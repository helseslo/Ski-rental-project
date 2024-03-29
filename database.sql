/* Usuwanie tabel oraz relacji w celu "wyzerowania bazy"  */

DROP TABLE lokacje CASCADE;
DROP TABLE stanowiska CASCADE;
DROP TABLE pracownicy CASCADE;
DROP TABLE kategorie CASCADE;
DROP TABLE sprzet CASCADE;
DROP TABLE cennik CASCADE;
DROP TABLE klienci CASCADE;
DROP TABLE rejestr CASCADE;
DROP TABLE rejestr_archiwalny CASCADE;

/* Tworzenie tabel */

CREATE TABLE lokacje (
    id_lokacji INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa_lokacji VARCHAR(50) UNIQUE NOT NULL,
    miasto VARCHAR(50) NOT NULL,
    ulica VARCHAR(50),
    nr_posesji VARCHAR(50) NOT NULL
);



CREATE TABLE stanowiska (
    id_stanowiska INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa_stanowiska VARCHAR(50) UNIQUE NOT NULL
);



CREATE TABLE pracownicy (
    id_pracownika INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    id_lokacji INTEGER REFERENCES lokacje(id_lokacji) ON UPDATE CASCADE ON DELETE CASCADE,
    id_stanowiska INTEGER REFERENCES stanowiska(id_stanowiska) ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE kategorie (
    id_kategorii INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa_kategorii VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE sprzet (
    id_sprzetu INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_kategorii INTEGER REFERENCES kategorie(id_kategorii) ON DELETE CASCADE ON UPDATE CASCADE,
    rozmiar INTEGER NOT NULL,
    firma VARCHAR(50),
    stan_wypozyczenia BOOLEAN DEFAULT (FALSE) NOT NULL,
    id_lokacji INTEGER REFERENCES lokacje(id_lokacji) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE cennik (
    cena DECIMAL(7,2) NOT NULL CHECK (cena > 0),
    kara DECIMAL(7,2) DEFAULT(1000) NOT NULL CHECK (kara > 0),
    id_lokacji INTEGER REFERENCES lokacje(id_lokacji) ON DELETE CASCADE ON UPDATE CASCADE,
    id_kategorii INTEGER REFERENCES kategorie(id_kategorii) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE klienci (
    id_klienta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    nr_telefonu VARCHAR(9) UNIQUE NOT NULL,
    nr_dowodu VARCHAR(8) UNIQUE NOT NULL,
    PESEL VARCHAR(11) UNIQUE NOT NULL,
    czarna_lista BOOLEAN DEFAULT (FALSE) NOT NULL
);


CREATE TABLE rejestr(
    id_wypozyczenia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_klienta INTEGER REFERENCES klienci(id_klienta) ON UPDATE CASCADE ON DELETE CASCADE,
    id_sprzetu INTEGER REFERENCES sprzet(id_sprzetu) ON UPDATE CASCADE ON DELETE CASCADE,
    data_wypozyczenia DATE DEFAULT(CURRENT_DATE) NOT NULL,
    data_zwrotu DATE CHECK (data_zwrotu > data_wypozyczenia) NOT NULL,
    maksymalne_przedluzenie DATE DEFAULT('3000-01-01') NOT NULL,
    podstawowy_koszt DECIMAL(7, 2) DEFAULT(0) CHECK (podstawowy_koszt >= 0) NOT NULL,
    naliczona_kara DECIMAL (7, 2) DEFAULT(0) CHECK (naliczona_kara >= 0) NOT NULL,
    czy_aktualne BOOLEAN DEFAULT (TRUE) NOT NULL
);

CREATE TABLE rejestr_archiwalny(
    id_wypozyczenia INTEGER,
    id_klienta INTEGER,
    id_sprzetu INTEGER,
    data_wypozyczenia DATE,
    data_zwrotu DATE,
    maksymalne_przedluzenie DATE,
    podstawowy_koszt DECIMAL(7, 2),
    naliczona_kara DECIMAL (7, 2)
);

/* Inserty - lokacje */
INSERT INTO lokacje (nazwa_lokacji, miasto, ulica, nr_posesji) VALUES ('St. Orczyk', 'Zloty Stok', 'Odjazdowa', 314);
INSERT INTO lokacje (nazwa_lokacji, miasto, ulica, nr_posesji) VALUES ('Nie na halny', 'Zajezdzone Nowe', 'Portowa', 5432);
INSERT INTO lokacje (nazwa_lokacji, miasto, ulica, nr_posesji) VALUES ('Bazowa', 'Wrocław', 'Matematyczna', 1);

/* Inserty - stanowiska */

INSERT INTO stanowiska (nazwa_stanowiska) VALUES ('Szef Wszystkich Szefow');
INSERT INTO stanowiska (nazwa_stanowiska) VALUES ('Grozny Wozny');
INSERT INTO stanowiska (nazwa_stanowiska) VALUES ('Sprzedawca bez latawca');

/* Inserty - pracownicy */
INSERT INTO pracownicy (imie, nazwisko, id_lokacji, id_stanowiska) VALUES ('Janusz', 'Alfa', 1, 1);
INSERT INTO pracownicy (imie, nazwisko, id_lokacji, id_stanowiska) VALUES ('Janusz', 'Beta', 1, 2);
INSERT INTO pracownicy (imie, nazwisko, id_lokacji, id_stanowiska) VALUES ('Areczek', 'Pracowity', 1, 3);
INSERT INTO pracownicy (imie, nazwisko, id_lokacji, id_stanowiska) VALUES ('Marta', 'Narta', 2, 3);

/* Inserty - kategorie */
INSERT INTO kategorie (nazwa_kategorii) VALUES ('Narty');
INSERT INTO kategorie (nazwa_kategorii) VALUES ('Kije');
INSERT INTO kategorie (nazwa_kategorii) VALUES ('Kaski');
INSERT INTO kategorie (nazwa_kategorii) VALUES ('Buty');

/* Inserty - sprzet */

/* narty */
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (1, 1, 'Narty wygrane w karty', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (1, 3, 'Narty wygrane w karty', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (1, 2, 'Narty wygrane w karty', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (1, 1, 'Sliska sprawa', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (1, 1, 'Narty znad Warty', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (1, 1, 'Sliska sprawa', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, stan_wypozyczenia, id_lokacji) VALUES (1, 2, 'Narty znad Warty', TRUE, 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (1, 3, 'Narty znad Warty', 2);
/* kije */
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (2, 1, 'Kije samobije', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (2, 2, 'Ten kij ma dwa konce', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (2, 3, 'Kije samobije', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (2, 1, 'Kij w mrowisko', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (2, 1, 'Ten kij ma dwa konce', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (2, 3, 'Ten kij ma dwa konce', 2);
/*kaski*/
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (3, 1, 'Glowa na karku', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (3, 2, 'Glowa na karku', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (3, 3, 'Glowa na karku', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (3, 3, 'Glowa na karku', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (3, 1, 'Glowa na karku', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (3, 2, 'Glowa na karku', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (3, 3, 'Glowa na karku', 2);
/*buty*/
INSERT INTO sprzet (id_kategorii, rozmiar, firma, stan_wypozyczenia, id_lokacji) VALUES (4, 1, 'Buty na luty', TRUE, 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (4, 2, 'Nie do pary', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (4, 3, 'Nie do pary', 1);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (4, 1, 'Buty na luty', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (4, 2, 'Buty na luty', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (4, 3, 'Nie do pary', 2);
INSERT INTO sprzet (id_kategorii, rozmiar, firma, id_lokacji) VALUES (4, 3, 'Nawet szewc w tych butach chodzi', 2);


/* Inserty - cennik */
/* narty */
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (50, 100, 1, 1);
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (60, 120, 2, 1);
/*kije*/
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (5, 10, 1, 2);
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (6, 12, 2, 2);
/*kaski*/
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (5, 10, 1, 3);
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (6, 12, 2, 3);
/*buty*/
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (5, 10, 1, 4);
INSERT INTO cennik (cena, kara, id_lokacji, id_kategorii) VALUES (6, 12, 2, 4);

/* Inserty - klienci */
INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, PESEL) VALUES ('Jurgen', 'Stokonen', '000000000', '123A', '01119911188');
INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, PESEL) VALUES ('Anna', 'Wciag-Wyciag', '111111111', '123B', '01010101011');
INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, PESEL) VALUES ('Tomasz', 'Anartniemasz', '222222222', '123C', '92128801012');
INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, PESEL) VALUES ('Czesław', 'Czarny', '666666666', 'ABC1', '88031388888');
INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, PESEL) VALUES ('Czesława', 'Czarna', '666666661', 'ABC2', '88031388881');
INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, PESEL, czarna_lista) VALUES ('Jack', 'Black', '666666662', 'ABC4', '88031388884', TRUE);
INSERT INTO klienci (imie, nazwisko, nr_telefonu, nr_dowodu, PESEL) VALUES ('Norbert', 'Spóźnialski', '123123333', 'ABC5', '88031388867');
/* Inserty - rejestr */
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, podstawowy_koszt) VALUES (1, 1, '2024-01-01', '2024-01-02', 1);
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, podstawowy_koszt) VALUES (1, 9, '2024-01-01', '2024-01-02', 1);
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, podstawowy_koszt) VALUES (2, 1, '2024-01-03', '2024-01-04', 1);
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, podstawowy_koszt) VALUES (2, 9, '2024-01-03', '2024-01-04', 1);
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, podstawowy_koszt, naliczona_kara) VALUES (3, 6, '2024-01-01', '2024-01-05', 100, 200);

INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, podstawowy_koszt, czy_aktualne) VALUES (3, 7, '2024-01-10', '2024-02-03', 50, TRUE);
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, maksymalne_przedluzenie, podstawowy_koszt, naliczona_kara, czy_aktualne) VALUES (4, 22, '2024-01-05', '2024-01-10', '2024-01-17', 36, 120, TRUE);

INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, maksymalne_przedluzenie, podstawowy_koszt, naliczona_kara, czy_aktualne) VALUES (5, 24, '2024-01-05', '2024-01-10', '2024-01-17', 36, 120, TRUE);
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, maksymalne_przedluzenie, podstawowy_koszt, naliczona_kara, czy_aktualne) VALUES (7, 25, '2024-01-05', '2024-01-10', '2024-01-17', 36, 120, TRUE);
INSERT INTO rejestr (id_klienta, id_sprzetu, data_wypozyczenia, data_zwrotu, maksymalne_przedluzenie, podstawowy_koszt, naliczona_kara, czy_aktualne) VALUES (6, 25, '2023-01-05', '2023-01-10', '2023-01-17', 36, 120, FALSE);
