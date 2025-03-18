from sklearn.linear_model import LinearRegression
from skopt import gp_minimize
from skopt.space import Integer
import numpy as np
import pandas as pd

combinations = {'m' : [],
                'M' : [],
                'n' : [],
                'mean' : [],
                'sd' : [],
                'SNPs' : [],
                'unique' : [],
                'FAIL': [],
                'CV' : [],
                'SNPs_per_locus' :[]}

with open("log_combinations.tsv", "r") as f:
    f.readline()

    for line in f.readlines():
        data = [x.strip() for x in line.split('\t')]
        n = 0
        for key in combinations.keys():
            if key == 'CV':
                combinations[key].append(float(data[4])/float(data[3]))
            elif key == 'SNPs_per_locus':
                combinations[key].append(float(data[5])/float(data[6]))
            else:
                if n in range(3,5):
                    value = float(data[n])
                else:
                    value = int(data[n])
                combinations[key].append(value)
            n += 1
    
df = pd.DataFrame(combinations)

search_space = [
    Integer(2,6, name='m'),
    Integer(0,4, name='M'),
    Integer(0,4, name='n')
]

models = {}

# Regressione per Mean: mean ~ m + M
X_mean = df[['m', 'M']]
y_mean = df['mean']
models["mean"] = LinearRegression().fit(X_mean, y_mean)

# Regressione per SD: sd ~ m
X_sd = df[['m']]
y_sd = df['sd']
models["sd"] = LinearRegression().fit(X_sd, y_sd)

# Regressione per SNPs: log(SNPs) ~ m + M + n
X_SNPs = df[['m', 'M', 'n']]
y_SNPs = np.log(df['SNPs'])
models["SNPs"] = LinearRegression().fit(X_SNPs, y_SNPs)

# Regressione per Unique: log(unique) ~ m + n
X_unique = df[['m', 'n']]
y_unique = np.log(df['unique'])
models["unique"] = LinearRegression().fit(X_unique, y_unique)


def objective(lista):
    global df

    m = lista[0]
    M = lista[1]
    n = lista[2]

    selected_row = df[(df['m'] == m) & (df['M'] == M) & (df['n'] == n)]
    
    if selected_row.empty:
        pred_values = {
            "mean": models["mean"].predict([[m, M]])[0],
            "sd": models["sd"].predict([[m]])[0],
            "SNPs": np.exp(models["SNPs"].predict([[m, M, n]])[0]),  # Inversione del log
            "unique": np.exp(models["unique"].predict([[m, n]])[0])  # Inversione del log
        }
        
        SNPs, unique, sd, mean = pred_values["SNPs"], pred_values["unique"], pred_values["sd"], pred_values["mean"]
        SNPs_per_locus = SNPs / unique
        CV = sd / mean
        if mean < 10 or unique < 2400:
            FAIL = 5
        else:
            FAIL = 0

        new_row = pd.DataFrame({
            'm' : [m],
            'M' : [M],
            'n' : [n],
            'mean' : [mean],
            'sd' : [sd],
            'SNPs' : [SNPs],
            'unique' : [unique],
            'FAIL' : [FAIL],
            'CV' : [CV],
            'SNPs_per_locus' : [SNPs_per_locus]
        })

        df = pd.concat([df, new_row], ignore_index = True)

    else:
        unique = selected_row['unique'].values[0]
        FAIL = selected_row['FAIL'].values[0]
        SNPs_per_locus = selected_row['SNPs_per_locus'].values[0]
        CV = selected_row['CV'].values[0]

    all_unique = df['unique']
    all_CV = df['CV']
    all_SNPs_per_locus = df['SNPs_per_locus']
    
    if FAIL == 5:
        normalised_SNP_per_locus = SNPs_per_locus/max(all_SNPs_per_locus)
        normalised_CV = CV/max(all_CV)
        normalised_unique = unique/max(all_unique)
    else:
        valid_rows = df[df['FAIL'] == 0]
        valid_SNPs_per_locus = valid_rows['SNPs_per_locus']
        valid_CV = valid_rows['CV']
        valid_unique = valid_rows['unique']

        normalised_SNP_per_locus = SNPs_per_locus / valid_SNPs_per_locus.max()
        normalised_CV = CV / valid_CV.max()
        normalised_unique = unique / valid_unique.max()
    
    final_metric = normalised_SNP_per_locus + normalised_CV + FAIL - normalised_unique

    return final_metric




result = gp_minimize(objective, search_space, n_calls=100, random_state=42)

print("Best result:", result.fun)
print("Best parameters:", result.x)