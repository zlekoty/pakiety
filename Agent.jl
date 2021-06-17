using Agents, Random, StatsBase
using InteractiveDynamics
using CairoMakie

mutable struct JeleńWilk <: AbstractAgent
    id::Int
    pos::Dims{2}
    type::Symbol # :jelen / :wilk
    energia::Float64
    narodziny::Float64
    Δenergia::Float64
end
    
#funkcje pomocnicze
Jelen(id, pos, energia, narodziny, Δe) = JeleńWilk(id, pos, :jelen, energia, narodziny, Δe)
Wilk(id, pos, energia, narodziny, Δe) = JeleńWilk(id, pos, :wilk, energia, narodziny, Δe)
    
function inicjalizacja_modelu(;
    il_jeleni = 100,
    il_wilków = 100,
    dims = (50, 50),
    Δenergia_jeleni = 8,
    Δenergia_wilków = 25,
    narodziny_jeleni = 0.04,
    narodziny_wilków = 0.05,
    seed = 23182,
)
    teren = GridSpace(dims, periodic = false)
    rng = MersenneTwister(seed)
    model = ABM(JeleńWilk, scheduler = Schedulers.randomly,teren)
    id = 0
    for _ in 1:il_jeleni
        id += 1
        energia = rand(1:(Δenergia_jeleni*2)) - 1
        jelen = Jelen(id, (0, 0), energia, narodziny_jeleni, Δenergia_jeleni)
        add_agent!(jelen, model)
    end
    for _ in 1:il_wilków
        id += 1
        energia = rand(1:(Δenergia_wilków*2)) - 1
        wilk = Wilk(id, (0, 0), energia, narodziny_wilków, Δenergia_wilków)
        add_agent!(wilk, model)
    end
    return model
end

function jeleńwilk_krok!(agent::JeleńWilk, model)
    if agent.type == :jelen
        jelen_krok!(agent, model)
        else # then `agent.type == :wilk`
        wilk_krok!(agent, model)
    end
end

function jelen_krok!(jelen, model)
    walk!(jelen, rand, model)
    jelen.energia -= 1
    jelen_je!(jelen, model)
    if jelen.energia < 0
        kill_agent!(jelen, model)
        return
    end
    if rand(model.rng) <= jelen.narodziny
        rozmnazaj!(jelen, model)
    end
end

function wilk_krok!(wilk, model)
    walk!(wilk, rand, model)
    wilk.energia -= 1
    agents = collect(agents_in_position(wilk.pos, model))
    obiad = filter!(x -> x.type == :jelen, agents)
    wilk_je!(wilk, obiad, model)
    if wilk.energia < 0
        kill_agent!(wilk, model)
        return
    end
    if rand(model.rng) <= wilk.narodziny
        rozmnazaj!(wilk, model)
    end
end

function jelen_je!(jelen, model)
    if sample([0,1],Weights([0.1,0.9]))==1
        jelen.energia += jelen.Δenergia
    end
end

function wilk_je!(wilk, jelen, model)
    if !isempty(jelen)
        obiad = rand(model.rng, jelen)
        kill_agent!(obiad, model)
        wilk.energia += wilk.Δenergia
    end
end
    
function rozmnazaj!(agent, model)
    agent.energia /= 2
    id = nextid(model)
    potomstwo = JeleńWilk(
        id,
        agent.pos,
        agent.type,
        agent.energia,
        agent.narodziny,
        agent.Δenergia,
    )
    add_agent_pos!(potomstwo, model)
    return
end

n=500
model = inicjalizacja_modelu()
        
#________________________FILM______________________________
offset(a) = a.type == :jelen ? (-0.7, -0.5) : (-0.3, -0.5)
ashape(a) = a.type == :jelen ? :circle : :utriangle
acolor(a) = a.type == :jelen ? RGBAf0(1.0, 1.0, 1.0, 1.0) : RGBAf0(0.2, 0.2, 0.2, 0.2)

            
plotkwargs = (
    ac = acolor,
    as = 15,
    am = ashape,
    offset = offset,)

    abm_video(
    "jelenwilk.mp4",
    model,
    jeleńwilk_krok!;
    frames = 100,
    framerate = 8,
    plotkwargs...)
                    
#___________________WYKRES_________________________________
jelen(a)=a.type == :jelen
wilk(a)=a.type == :wilk
adata = [(jelen, count), (wilk, count)]
adf,mdf = run!(model, jeleńwilk_krok!, n; adata)
                            
function wykres(adf)
    figure = Figure(resolution = (600, 400))
    ax = figure[1, 1] = Axis(figure; xlabel = "Krok", ylabel = "Populacja")
    jelenl = lines!(ax, adf.step, adf.count_jelen, color = :blue)
    wilkl = lines!(ax, adf.step, adf.count_wilk, color = :orange)
  
    figure[1, 2] = Legend(figure, [jelenl, wilkl], ["jelen", "wilk"])
    figure
end
wykres(adf)
