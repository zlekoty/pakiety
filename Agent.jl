using Agents, Random
using InteractiveDynamics
using CairoMakie
mutable struct JelenWilk <: AbstractAgent
    """tworzenie agentów:
    """
    id::Int
    pos::Dims{2}
    type::Symbol # :jelen / :wilk
    energia::Float64
    narodziny::Float64
    Δenergia::Float64
end
    
#funkcje pomocnicze
Jelen(id, pos, energia, narodziny, Δe) = JelenWilk(id, pos, :jelen, energia, narodziny, Δe)
Wilk(id, pos, energia, narodziny, Δe) = JelenWilk(id, pos, :wilk, energia, narodziny, Δe)
    
function inicjalizacja_modelu(;
    il_jeleni = 100,
    il_wilków = 50,
    dims = (20, 20),
    regrowth_time = 30,
    Δenergia_jeleni = 4,
    Δenergia_wilków = 20,
    narodziny_jeleni = 0.04,
    narodziny_wilków = 0.05,
    seed = 23182,
)
    space = GridSpace(dims, periodic = false)
    rng = MersenneTwister(seed)
    model = ABM(JelenWilk, scheduler = Schedulers.randomly,space)
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

function jelenwilk_krok!(agent::JelenWilk, model)
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
        reproduce!(jelen, model)
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
        reproduce!(wilk, model)
    end
end

function jelen_je!(jelen, model)
    if rand([0,1])==1
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
    
function reproduce!(agent, model)
    agent.energia /= 2
    id = nextid(model)
    potomstwo = JelenWilk(
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
    jelenwilk_krok!;
    frames = 150,
    framerate = 8,
    plotkwargs...
)
