# Modelling hub-and-spoke logistics networks with juggling

Master of Data Science research project (Part B), University of Adelaide, by Syed Uzair Shah Bukhari. It uses the mathematics of juggling and Markov chains to study when trucks pile up at a logistics hub, and what extra unloading bays are worth.

📄 **Plain-English write-up with diagrams:** [uzair-shah.github.io/projects/logistics-research.html](https://uzair-shah.github.io/projects/logistics-research.html)
📘 **Full report (PDF):** [`JugglingProgReportB_Bukhari_S_a1947793/JugglingProgReportB_Bukhari_S_a1947793.pdf`](JugglingProgReportB_Bukhari_S_a1947793/JugglingProgReportB_Bukhari_S_a1947793.pdf)

## The question

In a hub-and-spoke network, goods travel through one central hub. The hub can only unload so many trucks at once, so trucks arriving together have to wait, which costs money. **How do the number of unloading bays and truck travel times affect cost, revenue and profit at the hub?**

## The idea

- **Trucks are juggling balls**, and time moves in one-hour **beats**.
- A truck's travel time is its **throw height**: a truck back in 3 hours is a "3-throw".
- A **state** is the schedule of upcoming arrivals. For example, `110` means one truck arrives now, one in an hour, none in two hours.
- **Multiplex juggling** allows several catches per beat, which mirrors several trucks reaching the hub together.

## Method

1. Generate every possible arrival state and the moves between them (20 states for the main model).
2. Give each allowed move equal probability, which turns the state graph into a **Markov chain**.
3. Compute the chain's **stationary distribution**: the long-run share of time the hub spends in each state.
4. Run a **Monte Carlo simulation** (100,000 steps from every starting state, 30 random seeds), tracking cost and revenue at each step.
5. Check the simulation against theory using the residual sum of squares (RSSQ).

## Experiments and results

| Experiment | Setup | Profit |
|---|---|---|
| 1 | 1 bay, travel time up to 3 hours | −155,314.67 |
| 2 | 2 bays, up to 3 hours | **198,257.35** (the only profitable setup) |
| 3 | 3 bays, up to 3 hours | −3,139.73 |
| 4 | 1 bay, travel time doubled to 6 hours | −49,628.70 |

- The simulation matched the theory: RSSQ for the base model fell to 3.37 × 10⁻⁸.
- One bay loses the most money because two trucks often arrive together and pay delay costs.
- A third bay adds little: three trucks rarely arrive at once, so the bay sits idle while its cost is still paid.
- Doubling travel time lowers both cost and revenue.

**Caveat (from the report):** the model has not been calibrated or validated against a real hub-and-spoke network.

## Repository guide

| Path | What it is |
|---|---|
| `JugglingProgReportB_Bukhari_S_a1947793/main.tex` | LaTeX source of the report |
| `JugglingProgReportB_Bukhari_S_a1947793/*.pdf` | Compiled report |
| `JugglingProgReportB_Bukhari_S_a1947793/images/` | Figures used in the report |
| `Code/Term 2/CreateStMatrix_*.m` | Generate all states and transitions for each experiment (1, 2 or 3 bays; 3 or 6 hours) |
| `Code/Term 2/SimRun_*.m` | Run each experiment: transition matrix, stationary distribution, seeded simulation, costs, convergence plots |
| `Code/Term 2/RunSimMultSeedCorrStates.m` | Earlier multi-seed simulation of the 20-state model |
| `Code/Term 2/TotalStateCount.m` | Counts states with the stars-and-bars formula |
| `Code/Term 2/Figures/` | Saved MATLAB plots |
| `Code/Term 1/` | First-term exploratory simulations of smaller juggling systems |
| `Code/Term 2/Deprecated/`, `Code/Term 1/Old/` | Superseded drafts |
| `Excel_Files/*Bay*_Mat.xlsx` | States and transition tables for each experiment |
| `Excel_Files/Cost Results.xlsx` | Cost, revenue and profit for the four experiments |
| `Excel_Files/sum_states_2.xlsx`, `sumary_states.xlsx` | Simulated state probabilities grouped by simultaneous arrivals |
| `Excel_Files/TransitionMatrix.xlsx` | Transition matrices for earlier models |

## Running the code

Requires MATLAB. For each experiment, run the matching `CreateStMatrix_*.m` to build the states and transitions, then `SimRun_*.m` to simulate and compute costs:

| Experiment | Scripts |
|---|---|
| 1 | `CreateStMatrix_1Bay.m` → `SimRun_1Bay.m` |
| 2 | `CreateStMatrix_2Bay.m` → `SimRun_2Bay.m` |
| 3 | `CreateStMatrix_3Bay.m` → `SimRun_3Bay.m` |
| 4 | `CreateStMatrix_1Bay_6H.m` → `SimRun_1Bay_6H.m` |

To rebuild the report, compile `main.tex` with `pdflatex`.
