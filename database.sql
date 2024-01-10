DROP TABLE lokacje CASCADE;
DROP TABLE stanowiska CASCADE;
DROP TABLE pracownicy CASCADE;
DROP TABLE kategorie CASCADE;
DROP TABLE sprzet CASCADE;
DROP TABLE cennik CASCADE;
DROP TABLE klienci CASCADE;
DROP TABLE rejestr CASCADE;

CREATE TABLE lokacje (
    id_lokacji INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nazwa_lokacji VARCHAR(50) UNIQUE NOT NULL,
    miasto VARCHAR(50) NOT NULL,
    ulica VARCHAR(50),
    nr_posesji VARCHAR(50)
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
    id_lokacji INTEGER REFERENCES lokacje(id_lokacji) ON DELETE CASCADE ON UPDATE CASCADE,
    id_kategorii INTEGER REFERENCES kategorie(id_kategorii) ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE klienci (
    id_klienta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    nr_telefonu VARCHAR(50) UNIQUE NOT NULL,
    nr_dowodu VARCHAR(50) UNIQUE NOT NULL,
    PESEL VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE rejestr(
    id_wypozyczenia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    /*Czy tu na pewno chcemy przy delete usuwać wszystko? Czy to mają być aktualne wypoyczenia,
    czy historia tez?*/
    id_klienta INTEGER REFERENCES klienci(id_klienta) ON DELETE CASCADE ON UPDATE CASCADE,
    id_sprzetu INTEGER REFERENCES sprzet(id_sprzetu) ON DELETE CASCADE ON UPDATE CASCADE,
    data_wypozyczenia DATE NOT NULL,
    data_zwrotu DATE NOT NULL CHECK (data_zwrotu > data_wypozyczenia)
    /*Co, jeśli ktoś nie odda sprzętu w terminie? Dodatkowe atrybuty itd. Moze czarna lista, blok albo coś*/
);

