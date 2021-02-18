function process_result(job)
    try
        # TODO: When parsed check we dont have strange code
        result = @time eval.(parseall(job["code"]))[end]
        
        if isinf(result)
            printstyledln("[👉] Result: ∞";bold=true, color=:green)    
            return nothing
        end

        printstyledln("[👉] Done";bold=true, color=:green)

        return result
    catch error_message
        printstyledln("[❌] Failed with error:";bold=true, color=:red)
        # Just simply print if there is a failure with jsonify the error message
        try
            tabulate_and_pretty(JSON.json(error_message, 4))
        catch e
            println(e)
        end
        # Improved function output: better to be an struct of result + error
        return nothing
    end
end