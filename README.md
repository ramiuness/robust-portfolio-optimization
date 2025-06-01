# Robust Portfolio Optimization
Robust optimization (RO) extends traditional optimization models, by incorporating uncertainty as a parameter in the problem. RO extension models can be thought of as worst-case formulations of
the original problem, as far as the deviations of the parameters from their nominal values are concerned. In the context of RO, the uncertain parameters are assumed to belong to an uncertainty set, defined based on domain knowledge and information regarding the probability distributions of the parameters.

This repository provides illustrative code and a demonstration notebook for robust portfolio optimization models, inspired by the approaches described in the paper ["Robust optimization approaches for portfolio selection: a comparative analysis"](https://link.springer.com/article/10.1007/s10479-021-04177-y). The focus is on sharing coding methodology and results, rather than delivering a complete, production-ready software package.


I demonstrate that robustness with an elliptic uncertainty set significantly improves Sharpe ratio, Sortino ratio, CVaR, and Omega ratio, of the allocated portfolios, thus confirming the value of accounting for distributional uncertainty in portfolio design.
	    			    		

## Highlights

- **Demonstration Notebook:**  
  The included Jupyter notebook (`notebooks/robust_portfolio_optimization.ipynb`) illustrates the implementation of key concepts from the referenced paper, and presents the results obtained from applying robust optimization techniques to portfolio selection.
- **Sample Model Code:**  
  Example code files implement three core models (Mean-Variance, Omega-ratio, Robust Omega-ratio) to showcase the coding approach.
- **Educational Resource:**  
  Intended as a resource for researchers, students, and practitioners interested in robust portfolio optimization and quantitative finance.

## Tools & Technologies

- **Language:** Julia
- **Optimization:** JuMP, HiGhs, Gurobi
- **Statistical Models:** Gaussian Mixture Models
- **Notebook:** Jupyter (for demonstration and results)
- **Backtesting:** Rolling-window methodology

## Installation

1. Clone this repository:
    ```bash
    git clone https://github.com/ramiuness/robust-portfolio-optimization.git
    ```
2. (Optional) Install Gurobi and set up the license if you wish to use it as a solver.


## Usage

- Open the demo notebook in the `notebooks/` directory for an overview of the implementation and results.
- Explore the sample code files in the `src/` or main directory for illustrative model implementations.
- Adjust parameters and experiment with the code to suit your learning or research needs.

## Reference

If you use this code or methodology in your work, please cite the following paper:

> "Robust optimization approaches for portfolio selection: a comparative analysis." [Annals of Operations Research, 318(2), 611–639.](https://link.springer.com/article/10.1007/s10479-021-04177-y)

## License

This project is licensed under the [MIT License](LICENSE).

---

**Contact:** [ramiuness](https://github.com/ramiuness)
