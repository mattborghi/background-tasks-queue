function tabulate(string)
    return "\t" * replace(string, "\n" => "\n\t")
end

function tabulate_and_pretty(string)
    return printstyled("\n" * tabulate(string);bold=true, color=:blue)
end

function printstyledln(string; args...)
    return printstyled("\n\n" * string * "\n"; args...)
end