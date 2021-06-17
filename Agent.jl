using Agents, Random
mutable struct JelenWilk <: AbstractAgent
    """tworzenie agentów:
    """
    id::Int
    pos::Dims{2}
    type::Symbol # :jeleń / :wilk
    energia::Float64
    narodziny::Float64
    Δenergia::Float64
end

#funkcje pomocnicze
Jelen(id, pos, energia, narodziny, Δe) = JelenWilk(id, pos, :jelen, energia, narodziny, Δe)
Wilk(id, pos, energia, narodziny, Δe) = JelenWilk(id, pos, :wilk, energia, narodziny, Δe)

function inicjacja_modelu(;
    il_jeleni = 100,
    il_wilków = 50,
    dims = (20, 20),
    regrowth_time = 30,
    Δenergia_jeleni = 4,
    Δenergia_wilków = 20,
    narodziny_jeleni = 0.04,
    narodzinywilków = 0.05,
    seed = 23182,
)
    rng = MersenneTwister(seed)
    model = ABM(JelenWilk, scheduler = Schedulers.randomly)
    id = 0
    for  in 1:il_jeleni
        id += 1
        energia = rand(1:(Δenergia_jeleni2)) - 1
        jelen = Jelen(id, (0, 0), energia, narodziny_jeleni, Δenergia_jeleni)
        addagent!(jelen, model)
    end
    for  in 1:il_wilków
        id += 1
        energia = rand(1:(Δenergia_wilków2)) - 1
        wilk = Wilk(id, (0, 0), energia, narodziny_wilków, Δenergia_wilków)
        add_agent!(wilk, model)
    end
    return model
end
function jelenwilk_krok!(agent::JelenWilk, model)
    if agent.type == :jelen
        jelen_krok!(agent, model)
        else # then agent.type == :wilk
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
    agent.energy /= 2
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

model = inicjacja_modelu()