using Plots

jelenie_pocz=20.0 # ilosc poczatkowa ofiar
wilki_pocz=10.0 # ilosc poczatkowa drapieżników
narodziny_jeleni=0.9 # współczynnik urodzeń ofiar
szansa_upolowania=0.1 # szansa na upolowanie
narodziny_wilkow=0.5  # współczynnik urodzeń drapieżników
wsp_umier_wilkow=0.6 # współczynnik umieralnosci drapieżników

J = collect(10.0 for i in 1:1000) #macierz jeleni
J[1] = jelenie_pocz
W = collect(10.0 for i in 1:1000) #macierz wilków
W[1] = wilki_pocz


for i in 2:1000
    J[i] = J[i-1] + ((J[i-1]*narodziny_jeleni)-(szansa_upolowania*W[i-1]*J[i-1]))*0.04
    W[i] = W[i-1] + ((szansa_upolowania*narodziny_wilkow*J[i-1]*W[i-1]) - wsp_umier_wilkow*W[i-1])*0.04
end
    
