import AceEditor from "react-ace";

import 'brace/mode/julia';
import 'brace/snippets/julia'
import 'brace/theme/github';
import "brace/ext/language_tools";
import "brace/ext/searchbox";

export function JuliaEditor({ code, setCode }) {
    let placeholder = `
    Write the Julia code you want to run.

    An example code is the following:
    
    using Statistics
    using DifferentialEquations
    
    α=1
    β=1
    u₀=1/2
    f(u,p,t) = α*u
    g(u,p,t) = β*u
    dt = 1//2^(4)
    tspan = (0.0,1.0)
    prob = SDEProblem(f,g,u₀,(0.0,1.0))
    ensembleprob = EnsembleProblem(prob)
    sol = solve(ensembleprob; trajectories=1000)
    mean(sol[:, end])
    `
    return (
        <AceEditor
            placeholder={placeholder}
            mode="julia"
            theme="github"
            name="blah2"
            onChange={e => setCode(e)}
            fontSize={14}
            showPrintMargin={true}
            showGutter={true}
            highlightActiveLine={true}
            value={code}
            setOptions={{
                enableBasicAutocompletion: true,
                enableLiveAutocompletion: true,
                enableSnippets: true,
                showLineNumbers: true,
                tabSize: 4,
            }} />
    )
}