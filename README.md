# 🛡️ Robust Portfolio Optimization

This project implements and demonstrates robust portfolio optimization techniques that enhance classical models—such as Mean-Variance, CVaR, and Omega-ratio—by embedding **parameter estimation uncertainty directly into the optimization framework**. Inspired by the methods discussed in [*Robust optimization approaches for portfolio selection: a comparative analysis*](https://link.springer.com/article/10.1007/s10479-021-04177-y), this repository serves as an educational resource for understanding robust methods and their performance in portfolio design.

---

## 🌟 Key Features

- **Robustification of classical models**: Implements robust counterparts to traditional allocation models by accounting for uncertainty in mean returns.
- **Elliptic uncertainty sets**: Introduces worst-case-aware optimization using ellipsoidal perturbations of mean return estimates.
- **Improved performance**: Demonstrates significantly higher Sharpe, Sortino, CVaR, and Omega ratios under robust specifications.
- **Improved structure**: Achieves better diversification and lower turnover by producing more stable, balanced allocations that reduce concentration risk and transaction costs.
- **Rolling-window backtesting**: Evaluates how robust portfolios perform under real market dynamics, especially in volatile conditions.
- **Modular codebase**: Includes sample implementations of Mean-Variance and Omega portfolios and robust counterpart in a structured, inspectable format.

This framework highlights the practical value of **distributional robustness** in financial decision-making—ensuring that portfolios are optimized for **both expected performance and resilience to estimation uncertainty**.

---

## 📁 Repository Contents
- `notebooks/robust_portfolio_optimization.ipynb`:  
  Jupyter notebook showcasing the implementation and empirical results.
- `src/`:  
  Source code implementing robust optimization models and backtesting pipelines.
---

## 🛠 Tools & Technologies

### 🖥️ Language  
![Julia](https://img.shields.io/badge/Julia-9558B2?logo=julia&logoColor=white)

### 🔍 Optimization  
![JuMP](https://img.shields.io/badge/JuMP-00BFFF?logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyBmaWxsPSIjMDAwMDAwIiBoZWlnaHQ9IjEwMCIgd2lkdGg9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI%2BPC9zdmc%2B&label=JuMP)  
![HiGHS](https://img.shields.io/badge/HiGHS-0066CC?logo=gnu&logoColor=white)  
![Gurobi](https://img.shields.io/badge/Gurobi-EE1C25?logo=gurobi&logoColor=white)

### 📊 Statistical Models  
![Gaussian Mixture Models](https://img.shields.io/badge/Gaussian%20Mixture%20Models-6D4C41?style=flat&logo=scikit-learn&logoColor=white)

### 📓 Notebook  
![Jupyter](https://img.shields.io/badge/Jupyter-F37626?logo=jupyter&logoColor=white)

### 📈 Backtesting  
![Rolling Window](https://img.shields.io/badge/Rolling--Window--Backtesting-4CAF50?style=flat)

---

## 🚀 Usage

1. **Clone the repository**:
    ```bash
    git clone https://github.com/ramiuness/robust-portfolio-optimization.git
    ```
2. **Install dependencies**:
   - Install [Julia](https://julialang.org) and the required packages (`JuMP`, `HiGHS`, `Gurobi.jl` if licensed).
     
3. **Explore the source code**:
   - Review or modify the models in the `src/` directory to extend or adapt them to your own data or market assumptions.

---

## 📚 Reference

If you use this repository in your research, teaching, or applied work, please cite both the **original paper** and this **GitHub repository**:

> Antonios Georgantas, Michalis Doumpos & Constantin Zopounidis.  
> *Robust optimization approaches for portfolio selection: a comparative analysis*.  
> *Annals of Operations Research, 318(2), 611–639.*  
> [https://link.springer.com/article/10.1007/s10479-021-04177-y](https://link.springer.com/article/10.1007/s10479-021-04177-y)

