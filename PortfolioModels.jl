using DataFrames
using CSV
using Dates
using Distributions, Random
using LinearAlgebra, Statistics
using Plots
using JuMP, HiGHS, Gurobi
using MathOptInterface
using PrettyTables


############################################################################################################
###################################### Portfolio Models#####################################################
############################################################################################################

function compute_mv_weights(mean_rets::Matrix{Float64}, cov_matrix_rets::Matrix{Float64}, target_ret::Float64)
    """
    mean-variance optimization model
    mean_rets: mean returns of the assets
    cov_matrix_rets: covariance matrix of the asset returns
    target_ret: target return for the portfolio
    returns : optimal weights, mean return of the optimal portfolio, and the model.
    """
    n = size(mean_rets, 2)
      
    m  = Model(HiGHS.Optimizer)
    set_silent(m)
    @variable(m, x[1:n] >= 0)
    
    @constraint(m, sum(x) == 1)
    @constraint(m, dot(mean_rets, x) >= target_ret)
    
    @objective(m, Min, dot(x, cov_matrix_rets*x))
    
    optimize!(m)
    

    folio_weights = value.(x)
    folio_ret = dot(folio_weights, mean_rets)

    return folio_weights, folio_ret, objective_value(m), m
end


function compute_omega_ratio_weights(rets::Matrix{Float64}, mean_rets::Matrix{Float64}, tau::Float64, delta_range::Vector{Float64})
    """
    Omega ratio optimization model
    This function computes the optimal portfolio weights that maximize the Omega ratio
    while ensuring that the portfolio return is above the threshold tau.
      
    rets: matrix of returns (rows: time, columns: assets)
    mean_rets: mean returns of the assets
    tau: threshold return
    delta_range: range of delta values for the trade-off between return and loss
    
    returns : the optimal weights, mean return of the optimal portfolio, and the model.
    """ 
    function compute_weights(rets, mean_rets, tau, delta)

        n = size(rets, 2)
        T = size(rets, 1)
    
        m = Model(HiGHS.Optimizer)
        set_silent(m)
        
        @variable(m, x[1:n] >= 0)

        @variable(m, z[1:T] >= 0)  
        
        @constraint(m, sum(x) <= 1)
        @constraint(m, [i=1:T], z[i] >= tau - dot(rets[i, :], x))  
        @constraint(m, [i=1:T], z[i] >= 0)                         
        
        @objective(m, Max, delta*(dot(mean_rets,x) - tau) - (1 - delta) * mean(z))

        optimize!(m)
    
        return  value.(x), value.(z), objective_value(m), m
    end
     
    output = DataFrame(
            delta = Float64[],
            weights = Vector{Float64}[],
            folio_mean_ret = Float64[],
            mean_loss = Float64[],
            ret_loss_tradeOff = Float64[]
                
    );

    for d in delta_range

        w_opt, losses, omega, _ = compute_weights(rets, mean_rets, tau, d);
        push!(output, [d, w_opt, dot(w_opt, mean_rets), mean(losses), omega])
        
    end

    max_ret_idx = argmax(output.folio_mean_ret)

    opt_folio = output[max_ret_idx, :]

    return opt_folio.delta, opt_folio.weights, opt_folio.folio_mean_ret, opt_folio.mean_loss, opt_folio.ret_loss_tradeOff, output
end


function compute_romega_ratio_weights(rets, mixture_means, mixture_weights, tau, delta_range)
    """
    Robust Omega ratio optimization model for a mixture of distributions
    This function computes the optimal portfolio weights that maximize the Omega ratio
    while ensuring that the portfolio return is above the threshold tau.
    
    rets: matrix of returns (rows: time, columns: assets)
    mixture_means: matrix of mean returns for each mixture component
    mixture_weights: vector of weights for each mixture component
    tau: threshold return
    delta_range: range of delta values for the trade-off between return and loss
    returns : the optimal weights, mean return of the optimal portfolio, and the model.
    """
    function compute_weights(rets, mixture_means, tau, delta)

        n = size(rets[1],2)
        M = size(rets,1)
        T = [size(rets[i], 1) for i in 1:M]
        
        m = Model(HiGHS.Optimizer)
        set_silent(m)
        
        @variable(m, x[1:n] >= 0)
        @variable(m, theta >= 0)
        
        z_vars = Dict{Int, Vector{VariableRef}}()
        
        for k in 1:M
            z_vars[k] = @variable(m, [1:T[k]]) 
        end  
         
        @constraint(m, sum(x) == 1)
        @constraint(m, [k=1:M], z_vars[k] .>= 0) 
        @constraint(m, [k=1:M], z_vars[k] .>= tau - rets[k]*x)  # Lower bound constraint
        @constraint(m, [k=1:M], delta*(dot(mixture_means[k],x) - tau) - (1 - delta) * mean(z_vars[k]) .>= theta)                
        
        @objective(m, Max, theta)
        
        optimize!(m)    
    
        return  value.(x), objective_value(m), m
    end
     
    output = DataFrame(
            delta = Float64[],
            weights = Vector{Float64}[],
            folio_mean_ret = Float64[],
            ret_loss_tradeOff = Float64[]
                
    );

    mean_rets = sum([mean(rets_sampled[i], dims=1)*mixture_weights[i] for i in 1:size(mixture_weights,1)]) 

    for d in delta_range

        w_opt, omega, _ = compute_weights(rets, mixture_means, tau, d);
        push!(output, [d, w_opt, dot(w_opt, mean_rets), omega])
        
    end

   
    max_ret_idx = argmax(output.folio_mean_ret)

    
    opt_folio = output[max_ret_idx, :]

    return opt_folio.delta, opt_folio.weights, opt_folio.folio_mean_ret, opt_folio.ret_loss_tradeOff, output
end


############################################################################################################
#####################################Utility functions######################################################
############################################################################################################

function run_models(rets::Matrix{Float64}, mean_rets::Matrix{Float64}, cov_matrix_rets::Matrix{Float64}, 
                    cov_matrix_mean_estimation::Diagonal{Float64, Vector{Float64}}, 
                    target_ret=0.0001, alpha=0.05, beta=0.95)
    """
    Run various portfolio optimization models and return the weights for each model.
    rets: matrix of returns (rows: time, columns: assets)
    mean_rets: mean returns of the assets
    cov_matrix_rets: covariance matrix of the asset returns
    cov_matrix_mean_estimation: diagonal matrix for mean estimation
    target_ret: target return for the portfolio
    alpha: significance level for the mean-variance utility model
    beta: confidence level for the CVaR model
    returns : dictionary with model names as keys and their corresponding weights as values
    """
    
    w_mv, mv_ret, _, _ = compute_mv_weights(mean_rets, cov_matrix_rets, target_ret)
    w_cvar, _, _, _, _ = compute_cvar_weights(rets, mean_rets, beta, target_ret) 
    _, w_omega, _, _, _, _ = compute_omega_ratio_weights(rets, mean_rets, 0.0, collect(0.6:0.05:0.85))
    w_mvbu, _, _, _ = compute_mvbu_weights(rets, mean_rets, cov_matrix_rets, target_ret, alpha)
    w_mveu, _, _, _ = compute_mveu_weights(mean_rets, cov_matrix_rets, cov_matrix_mean_estimation, target_ret, 1-alpha)
    
    return Dict("MV" => w_mv,
                "CVaR" => w_cvar,
                "Omega" => w_omega,
                "MVBU" => w_mvbu,
                "MVEU" => w_mveu
                )
end

function prefilter_data(rets::DataFrame, start_date::Date, end_date::Date; estimation_period=Year(1), testing_period=Month(3))
    """
    Pre-filter the data for rolling windows of estimation and testing periods.
    This function generates a list of windows with estimation and testing periods,
    and extracts the relevant data for each window.

    rets: DataFrame containing asset returns with a 'Date' column
    start_date: start date for the analysis
    end_date: end date for the analysis
    estimation_period: duration of the estimation period (default is 1 year)
    testing_period: duration of the testing period (default is 3 months)
    returns : dictionary with windows as keys and tuples of estimation data and returns to date as values
    """

    windows = []
    current_start = start_date
    while current_start + estimation_period <= end_date
        push!(windows, (
            estimation_start = current_start,
            estimation_end = current_start + estimation_period - Day(1),
            testing_start = current_start + estimation_period,
            testing_end = current_start + estimation_period + testing_period - Day(1)
        ))
        current_start += Month(3)
    end

    pre_filtered_data = Dict()
    for window in windows
        estimation_data = rets[(rets.Date .>= window.estimation_start) .& (rets.Date .<= window.estimation_end), :]
        returns_to_date = Matrix(select(rets[rets.Date .<= window.estimation_end, :], Not(:Date)))

        pre_filtered_data[window] = (
            estimation_data = estimation_data,
            returns_to_date = returns_to_date
        )
    end

    return pre_filtered_data
end

function compute_rolling_test_data(rets::DataFrame, start_date::Date, end_date::Date; 
                                             estimation_period=Year(1), testing_period=Month(3))
    """
    Compute rolling windows of estimation and testing data for portfolio optimization models.
    This function generates a DataFrame with the results of the portfolio optimization models
    for each window, including the estimation and testing periods, model names, and weights.
    rets: DataFrame containing asset returns with a 'Date' column
    start_date: start date for the analysis
    end_date: end date for the analysis
    estimation_period: duration of the estimation period (default is 1 year)
    testing_period: duration of the testing period (default is 3 months)
    returns : DataFrame with columns for estimation start, estimation end, testing start, testing end,
              model name, and weights for each model.
    """
    
    pre_filtered_data = prefilter_data(rets, start_date, end_date; 
                                       estimation_period=estimation_period, testing_period=testing_period)

    results = DataFrame(
        estimation_start = Date[],
        estimation_end = Date[],
        testing_start = Date[],
        testing_end = Date[],
        model = String[],
        weights = Vector{Float64}[]
    )

    for (window, data) in pre_filtered_data
        estimation_data, returns_to_date = data.estimation_data, data.returns_to_date

        mean_rets = mean(returns_to_date, dims=1)
        cov_matrix_rets = cov(returns_to_date)
        std_devs = std(returns_to_date, dims=1)
        cov_matrix_mean_estimation = Diagonal(std_devs[:])

        try
            rets_matrix = Matrix(select(estimation_data, Not(:Date)))
            weights = run_models(rets_matrix, mean_rets, cov_matrix_rets, cov_matrix_mean_estimation)
            for (model, w) in weights
                push!(results, (window.estimation_start, window.estimation_end, window.testing_start, window.testing_end, model, w))
            end
        catch e
            @warn "Failed to process models for period $(window.estimation_start)-$(window.estimation_end): $e"
        end
    end

    return results
end


