using Plots
using Random

function stan_początkowy(ilość_pocz)
    """
    Funkcja tworzy macierz, której pierwszym elementem jest początkowa populacja zwierząt,
    a kolejnymi zera. Kolejne elementy będą reprezentować populację w danym czasie.

    Argumenty
    ---------
    ilość_pocz(Float): początkowa populacja zwierząt
    """
    P = zeros(24999) 
    P[1] = ilość_pocz
    return P
end

J = stan_początkowy(20.0) #macierz jeleni
W = stan_początkowy(20.0) #macierz wilków

#Symulacja bez uwzględnienia elementu losowego

function zmiana(narodziny_jeleni, szansa_upolowania, pojemność_środowiskowa = 500, narodziny_wilków = 0.5, wsp_umier_wilków = 0.6)
    """
    Funkcja modyfikuje kolejne elementy macierzy J i W tak, aby reprezentowały zmieniającą się liczbę osobników
    populacji jeleni oraz wilków.

    Argumenty
    ---------
    narodziny_jeleni(Float): tempo rozmnażania się jeleni
    szansa_upolowania(Float): szansa na upolowanie jelenia przez wilka
    pojemność_środowiskowa(Float): maksymalna ilość jeleni w środowisku
    narodziny_wilków(Float): tempo rozmnażania się wilków
    wsp_umier_wilków(Float): tempo umieralności wilków
    """
    global J
    global W 
    for i in 2:24999 
        if J[i-1] < 0.01
            J[i] = 0
        else
            J[i] = J[i-1] + ((J[i-1]*narodziny_jeleni)-(szansa_upolowania*W[i-1]*J[i-1]))*(1-J[i-1]/pojemność_środowiskowa)*0.002
        end
        if W[i-1] < 0.01
            W[i] = 0
        else
            W[i] = W[i-1] + ((szansa_upolowania*narodziny_wilków*J[i-1]*W[i-1]) - wsp_umier_wilków*W[i-1])*0.002
        end           
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
        J = stan_początkowy(20.0)
        W = stan_początkowy(20.0)
        zmiana(k/250, 0.05)
        plot(J, title = "Współczynnik narodzin jeleni: "*string(k/250), label = "ilość jeleni", ylabel = "liczba osobników", xlabel = "czas")
        plot!(W, label = "ilość wilków")   
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
    an = @animate for k in 1:500 # k/2000 jest szansą upolowania jelenia przez wilka
        J = stan_początkowy(20.0)
        W = stan_początkowy(20.0)
        zmiana(0.9, k/1000)
        plot(J, title = "Szansa upolowania: "*string(k/2000), label = "ilość jeleni", ylabel = "liczba osobników", xlabel = "czas")
        plot!(W, label = "ilość wilków") 
        
    end
    gif(an, fps = 10)
end

#Symulacja z uwzględnieniem elementu losowego

function losowa_zmiana_parametru(parametr, X)
    """
    Zwraca wartość, która jest losowo zmodyfikowaną watością parametru. Im większa wartość X, 
    tym wahania będą niższe. Jednocześnie X nie powinien być mniejszy od 1.
    """
    if X >= 1
        zakres_zmiany = LinRange(-parametr/X, parametr/X, 100)
        losowy_wybór = rand(zakres_zmiany)
        nowa_wartość = parametr + losowy_wybór
        return nowa_wartość
    end
end

function zmiana_losowa(narodziny_jeleni, szansa_upolowania, X = 1, pojemność_środowiskowa = 500, narodziny_wilków = 0.5, wsp_umier_wilków = 0.6)
    """
    Funkcja modyfikuje w sposób losowy kolejne elementy macierzy J i W tak, aby reprezentowały zmieniającą się liczbę osobników
    populacji jeleni oraz wilków.

    Argumenty
    ---------
    narodziny_jeleni(Float): tempo rozmnażania się jeleni
    szansa_upolowania(Float): szansa na upolowanie jelenia przez wilka
    X(Float): współczynnik losowości zmiany (powinien być większy od 1, a im większy, tym losowość mniejsza)
    pojemność_środowiskowa(Float): maksymalna ilość jeleni w środowisku
    narodziny_wilków(Float): tempo rozmnażania się wilków
    wsp_umier_wilków(Float): tempo umieralności wilków
    """
    global J
    global W
    J = stan_początkowy(20.0)
    W = stan_początkowy(20.0)   
    for i in 2:24999
        los_szansa_upolowania = losowa_zmiana_parametru(szansa_upolowania, X)

        if J[i-1] < 0.1
            J[i] = 0
        else
            los_narodziny_jeleni = losowa_zmiana_parametru(narodziny_jeleni, X)  
            J[i] = J[i-1] + ((J[i-1]*los_narodziny_jeleni)-(los_szansa_upolowania*W[i-1]*J[i-1]))*(1-J[i-1]/pojemność_środowiskowa)*0.002
        end

        if W[i-1] < 0.1
            W[i] = 0
        else
            los_narodziny_wilków = losowa_zmiana_parametru(narodziny_wilków, X)
            los_wsp_umier_wilków = losowa_zmiana_parametru(wsp_umier_wilków, X)  
            W[i] = W[i-1] + ((los_szansa_upolowania*los_narodziny_wilków*J[i-1]*W[i-1]) - los_wsp_umier_wilków*W[i-1])*0.002
        end                    
    end
end

#Symulacja z uwzględnieniem kataklizmów

function kataklizm(szansa)
    """
    Funkcja zwraca "susza", jeśli kataklizm nastąpił lub "false", jeśli nie nastąpił.

    Argumenty
    ---------
    szansa(Float): procentowa szansa na wystąpienie kataklizmu
    """
    czy_kataklizm = rand()*100
    if szansa >= czy_kataklizm
        return "susza"
    else
        return false
    end
end

function zmiana_z_kataklizmami(narodziny_jeleni, szansa_upolowania, szansa = 0.1, pojemność_środowiskowa = 500, narodziny_wilków = 0.5, wsp_umier_wilków = 0.6)
    """
    Funkcja modyfikuje kolejne elementy macierzy J i W tak, aby reprezentowały zmieniającą się liczbę osobników
    populacji jeleni oraz wilków. Jeśli w danym czasie nastąpi kataklizm, współczynniki zmieniają się na 50 jednostek czasu.

    Argumenty
    ---------
    narodziny_jeleni(Float): tempo rozmnażania się jeleni
    szansa_upolowania(Float): szansa na upolowanie jelenia przez wilka
    szansa(Float): procentowa szansa na wystąpienie kataklizmu w jednostce czasu
    pojemność_środowiskowa(Float): maksymalna ilość jeleni w środowisku
    narodziny_wilków(Float): tempo rozmnażania się wilków
    wsp_umier_wilków(Float): tempo umieralności wilków
    """
    global J
    global W
    J = stan_początkowy(20.0)
    W = stan_początkowy(20.0)  
    czas_kataklizmu = 0 
    for i in 2:24999 
        if czas_kataklizmu > 0
            czas_kataklizmu -= 1
            aktualne_narodziny_jeleni = narodziny_jeleni/10
            aktualny_wsp_umier_wilków = 1.8*wsp_umier_wilków
        else
            aktualne_narodziny_jeleni = narodziny_jeleni
            aktualny_wsp_umier_wilków = wsp_umier_wilków
        end  
        
        if J[i-1] < 0.1
            J[i] = 0
        else
            J[i] = J[i-1] + ((J[i-1]*aktualne_narodziny_jeleni)-(szansa_upolowania*W[i-1]*J[i-1]))*(1-J[i-1]/pojemność_środowiskowa)*0.002
        end
        if W[i-1] < 0.1
            W[i] = 0
        else
            W[i] = W[i-1] + ((szansa_upolowania*narodziny_wilków*J[i-1]*W[i-1]) - aktualny_wsp_umier_wilków*W[i-1])*0.002
        end  
        
        if kataklizm(szansa) == "susza"
            czas_kataklizmu = 50
        end
    end
end

function zmiana_losowa_z_kataklizmami(narodziny_jeleni, szansa_upolowania, X = 1, szansa = 0.1, pojemność_środowiskowa = 500, narodziny_wilków = 0.5, wsp_umier_wilków = 0.6)
    """
    Funkcja modyfikuje w sposób losowy kolejne elementy macierzy J i W tak, aby reprezentowały zmieniającą się liczbę osobników
    populacji jeleni oraz wilków. Jeśli w danym czasie nastąpi kataklizm, współczynniki zmieniają się na 50 jednostek czasu.

    Argumenty
    ---------
    narodziny_jeleni(Float): tempo rozmnażania się jeleni
    szansa_upolowania(Float): szansa na upolowanie jelenia przez wilka
    X(Float): współczynnik losowości zmiany (powinien być większy od 1, a im większy, tym losowość mniejsza)
    szansa(Float): procentowa szansa na wystąpienie kataklizmu w jednostce czasu
    pojemność_środowiskowa(Float): maksymalna ilość jeleni w środowisku
    narodziny_wilków(Float): tempo rozmnażania się wilków
    wsp_umier_wilków(Float): tempo umieralności wilków
    """
    global J
    global W
    J = stan_początkowy(20.0)
    W = stan_początkowy(20.0)  
    czas_kataklizmu = 0 
    for i in 2:24999 
        if czas_kataklizmu > 0
            czas_kataklizmu -= 1
            los_narodziny_jeleni = 0
            los_wsp_umier_wilków = 1
        else
            los_narodziny_jeleni = losowa_zmiana_parametru(narodziny_jeleni, X)
            los_wsp_umier_wilków = losowa_zmiana_parametru(wsp_umier_wilków, X)
        end
        los_szansa_upolowania = losowa_zmiana_parametru(szansa_upolowania, X)
        los_narodziny_wilków = losowa_zmiana_parametru(narodziny_wilków, X)
         
        if J[i-1] < 0.1
            J[i] = 0
        else
            J[i] = J[i-1] + ((J[i-1]*los_narodziny_jeleni)-(los_szansa_upolowania*W[i-1]*J[i-1]))*(1-J[i-1]/pojemność_środowiskowa)*0.002        
        end

        if W[i-1] < 0.1
            W[i] = 0
        else
            W[i] = W[i-1] + ((los_szansa_upolowania*los_narodziny_wilków*J[i-1]*W[i-1]) - los_wsp_umier_wilków*W[i-1])*0.002
        end
        
        if kataklizm(szansa) == "susza"
            czas_kataklizmu = 50
        end
    end
end

# Wykres

function wykres(narodziny_jeleni, szansa_upolowania, czy_losowe = false, czy_kataklizm = false) # Przykładowo: wykres(0.9, 0.05)
    """
    Funckja rysuje wykres pokazujący zależność między ilością jeleni a ilością wilków,
    w zależności od zadanych parametrów.

    Argumenty
    ---------
    narodziny_jeleni(Float): tempo rozmnażania się jeleni
    szansa_upolowania(Float): szansa na upolowanie jelenia przez wilka
    czy_losowe(Bool): określa czy wykres ma zawierać element losowy
    czy_kataklizm(Bool): określa czy wykres ma uwzględniać kataklizmy
    """
    global J
    global W
    J = stan_początkowy(20.0)
    W = stan_początkowy(20.0)
    if czy_losowe && czy_kataklizm
        zmiana_losowa_z_kataklizmami(narodziny_jeleni, szansa_upolowania)
    elseif czy_losowe
        zmiana_losowa(narodziny_jeleni, szansa_upolowania)
    elseif czy_kataklizm
        zmiana_z_kataklizmami(narodziny_jeleni, szansa_upolowania)
    else
        zmiana(narodziny_jeleni, szansa_upolowania)
    end
    plot(J, label="ilość jeleni", ylabel= "liczba osobników", xlabel = "czas")
    plot!(W, label = "ilość wilków")
end

# Symulacja z uwzględnieniem cztereh gatunków

J1 = stan_początkowy(20)
J2 = stan_początkowy(20)
W1 = stan_początkowy(20)
W2 = stan_początkowy(20)

function zmiana_4gatunki(narodziny_jeleni_1 = 1.1, narodziny_jeleni_2 = 0.9, szansa_upolowania_1 = 0.055, szansa_upolowania_2 = 0.05, narodziny_wilków = 0.5, wsp_umier_wilków_1 = 0.5, wsp_umier_wilków_2 = 0.55, pojemność_wilków = 150, pojemność_jeleni = 400)
    """
    Funkcja modyfikuje kolejne elementy macierzy J1, J2, W1 i W2 tak, aby reprezentowały zmieniającą się liczbę osobników
    populacji jeleni 1, jeleni 2, wilków 1 oraz wilków 2 w czasie.

    Argumenty
    ---------
    narodziny_jeleni_1/2(Float): tempo rozmnażania się jeleni 1/2
    szansa_upolowania_1/2(Float): szansa na upolowanie jelenia przez wilka 1/2
    pojemność_jeleni/wilków(Float): maksymalna ilość jeleni/wilków w środowisku
    narodziny_wilków(Float): tempo rozmnażania się wilków
    wsp_umier_wilków_1/2(Float): tempo umieralności wilków 1/2
    """
    global J1, J2, W1, W2

    J1 = stan_początkowy(30)
    J2 = stan_początkowy(30)
    W1 = stan_początkowy(10)
    W2 = stan_początkowy(10)

    for i in 2:24999
        polowanie = rand(0:2)

        if J1[i-1] == 0 || polowanie == 2 # Wilki polują tylko na jelenie 2.
            W1[i] = W1[i-1] + ((1 - W1[i-1]/pojemność_wilków)*(szansa_upolowania_1*narodziny_wilków*J2[i-1]*W1[i-1]) - wsp_umier_wilków_1*W1[i-1])*0.002
            W2[i] = W2[i-1] + ((1 - W2[i-1]/pojemność_wilków)*(szansa_upolowania_2*narodziny_wilków*J2[i-1]*W2[i-1]) - wsp_umier_wilków_2*W2[i-1])*0.002
            J1[i] = J1[i-1] + (1- J1[i-1]/pojemność_jeleni)*(J1[i-1]*narodziny_jeleni_1)*0.002
            J2[i] = J2[i-1] + ((1- J2[i-1]/pojemność_jeleni)*(J2[i-1]*narodziny_jeleni_2) - (szansa_upolowania_1*W1[i-1]*J2[i-1]) - (szansa_upolowania_2*W2[i-1]*J2[i-1]))*0.002
            
        elseif J2[i-1] == 0 || polowanie == 1 # Wilki polują tylko na jelenie 1.
            W1[i] = W1[i-1] + ((1 - W1[i-1]/pojemność_wilków)*(szansa_upolowania_1*narodziny_wilków*J1[i-1]*W1[i-1]) - wsp_umier_wilków_1*W1[i-1])*0.002
            W2[i] = W2[i-1] + ((1 - W2[i-1]/pojemność_wilków)*(szansa_upolowania_2*narodziny_wilków*J1[i-1]*W2[i-1]) - wsp_umier_wilków_2*W2[i-1])*0.002
            J1[i] = J1[i-1] + ((1- J1[i-1]/pojemność_jeleni)*(J1[i-1]*narodziny_jeleni_1) - (szansa_upolowania_1*W1[i-1]*J1[i-1]) - (szansa_upolowania_2*W2[i-1]*J1[i-1]))*0.002
            J2[i] = J2[i-1] + (1- J2[i-1]/pojemność_jeleni)*(J2[i-1]*narodziny_jeleni_2)*0.002

        else # Wilki 1 polują na jelenie 2, wilki 2 na jelenie 1.
            W1[i] = W1[i-1] + ((1 - W1[i-1]/pojemność_wilków)*(szansa_upolowania_1*narodziny_wilków*J2[i-1]*W1[i-1]) - wsp_umier_wilków_1*W1[i-1])*0.002
            W2[i] = W2[i-1] + ((1 - W2[i-1]/pojemność_wilków)*(szansa_upolowania_2*narodziny_wilków*J1[i-1]*W2[i-1]) - wsp_umier_wilków_2*W2[i-1])*0.002
            J1[i] = J1[i-1] + ((1- J1[i-1]/pojemność_jeleni)*(J1[i-1]*narodziny_jeleni_1) - (szansa_upolowania_2*W2[i-1]*J1[i-1]))*0.002
            J2[i] = J2[i-1] + ((1- J2[i-1]/pojemność_jeleni)*(J2[i-1]*narodziny_jeleni_2) - (szansa_upolowania_1*W1[i-1]*J2[i-1]))*0.002
        end
    end
end

function wykres_4gatunki(narodziny_jeleni_1 = 1.1, narodziny_jeleni_2 = 0.9, szansa_upolowania_1 = 0.055, szansa_upolowania_2 = 0.05, narodziny_wilków = 0.5, wsp_umier_wilków_1 = 0.5, wsp_umier_wilków_2 = 0.55, pojemność_wilków = 150, pojemność_jeleni = 400)
    global J1, J2, W1, W2
    J1 = stan_początkowy(30)
    J2 = stan_początkowy(30)
    W1 = stan_początkowy(10)
    W2 = stan_początkowy(10)

    zmiana_4gatunki(narodziny_jeleni_1, narodziny_jeleni_2, szansa_upolowania_1, szansa_upolowania_2, narodziny_wilków, wsp_umier_wilków_1, wsp_umier_wilków_2, pojemność_wilków, pojemność_jeleni)
    plot(J1, label="ilość jeleni 1", ylabel= "liczba osobników", xlabel = "czas")
    plot!(J2, label="ilość jeleni 2")
    plot!(W1, label="ilość wilków 1")
    plot!(W2, label="ilość wilków 2")
end
