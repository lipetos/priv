local Table = {}

function Table.WeightRandom(Table)
    local w = 0

    for i,v in Table do
        w += v * 10
    end

    local r = math.random(1, w)

    w = 0

    for i,v in Table do
        w += v * 10

        if w >= r then
            return i
        end
    end
end

function Table.ShallowCopy(tab)
    local new_tab = {}

    for i,v in tab do
        new_tab[i] = v
    end

    return new_tab
end

return Table