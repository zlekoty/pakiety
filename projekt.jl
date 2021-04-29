using Plots

function stan_początkowy_jeleni(jelenie_pocz)
    """
    Funkcja tworzy macierz, której pierwszym elementem jest początkowa ilość jeleni,
    a kolejnymi zera. Kolejne elementy będą reprezentować ilość jeleni w danym czasie.
    """
    J = zeros(24999) 
    J[1] = jelenie_pocz
    return J
end

function stan_początkowy_wilków(wilki_pocz)
    """
    Funkcja tworzy macierz, której pierwszym elementem jest początkowa ilość wilków,
    a kolejnymi zera. Kolejne elementy będą reprezentować ilość wilków w danym czasie.
    """
    W = zeros(24999)
    W[1] = wilki_pocz
    return W
end

J = stan_początkowy_jeleni(20.0)
W = stan_początkowy_wilków(10.0)
pojemność_środowiskowa = 500 # Pojemność środowiskowa dla jeleni. Im bliżej ich populacja zbliża się do tej liczby, tym wolniej się rozmnażają.
narodziny_wilkow = 0.5  # Współczynnik urodzeń drapieżników.
wsp_umier_wilkow = 0.6 # Współczynnik umieralnosci drapieżników.

function zmiana(narodziny_jeleni, szansa_upolowania)
    """
    Funkcja modyfikuje kolejne elementy macierzy J i W tak, aby reprezentowały zmieniającą się liczbę osobników
    populacji jeleni oraz wilków.
    """
    global pojemność_środowiskowa
    global J
    global W 
    global narodziny_wilkow
    global wsp_umier_wilkow
    for i in 2:24999  
        J[i] = J[i-1] + ((J[i-1]*narodziny_jeleni)-(szansa_upolowania*W[i-1]*J[i-1]))*(1-J[i-1]/pojemność_środowiskowa)*0.002
        W[i] = W[i-1] + ((szansa_upolowania*narodziny_wilkow*J[i-1]*W[i-1]) - wsp_umier_wilkow*W[i-1])*0.002
    end
end

function anim_narodziny_jeleni()
    """
    Funkcja tworzy animację zmieniających się populcji w zależności od współczynnika narodzin jeleni.
    Oscyluje on między wartością 0.04 a 2.
    """
    global J
    global W
    an = @animate for k in 1:500 # k/250 jest współczynnikiem urodzin jeleni
        zmiana(k/250, 0.05)
        plot(J, title = "Wykres w zależności od współczynnika narodzin jeleni", label = "ilość jeleni", ylabel = "liczba osobników", xlabel = "czas")
        plot!(W, label = "ilość wilków") 
        J = stan_początkowy_jeleni(20.0)
        W = stan_początkowy_wilków(10.0)
    end
    gif(an, fps = 10)
end

function anim_szansa_upolowania()
    """
    Funkcja tworzy animację zmieniających się populcji w zależności od szansy upolowania jelenia przez wilka.
    Oscyluje on między wartością 0.001 a 0.5.
    """
    global J
    global W
    an = @animate for k in 1:500 # k/1000 jest szansą upolowania jelenia przez wilka
        zmiana(0.9, k/1000)
        plot(J, title = "Wykres w zależności od szansy upolowania", label = "ilość jeleni", ylabel = "liczba osobników", xlabel = "czas")
        plot!(W, label = "ilość wilków") 
        J = stan_początkowy_jeleni(20.0)
        W = stan_początkowy_wilków(10.0)
    end
    gif(an, fps = 10)
end

function wykres(narodziny_jeleni, szansa_upolowania) # Przykładowo: wykres(0.9, 0.05)
    """
    Funckja rysuje wykres pokazujący zależność między ilością jeleni a ilością wilków,
    w zależności od zadanych parametrów.
    """
    global J
    global W
    J = stan_początkowy_jeleni(20.0)
    W = stan_początkowy_wilków(10.0)
    zmiana(narodziny_jeleni, szansa_upolowania)
    plot(J, label="ilość jeleni", ylabel= "liczba osobników", xlabel = "czas")
    plot!(W, label = "ilość wilków")
end
