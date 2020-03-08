# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.3.5
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
# ---

# # Quante persone saranno contagiate?

# Si vedono tante proiezioni sui contagiati, tutte fanno vedere una curva esponenziale (che shizza verso l'alto).
# Questo effetto piuttosto drammatico è dato più dalla scelta del modello statistico che dai dati in sè.
#
# In questo notebook confrontiamo il modello esponenziale con un modello più sobrio, che tiene conto del più comune andamento dei fenomeni biologici: cioè una rapida crescita seguita da un assestamento. Faremo anche una predizione su quando avverrà questo assestamento.
#
# Per cominciare importiamo le librerie, carichiamo i dati e facciamo una pulizia.

# +
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from lmfit import Model

df = pd.read_csv('./../publication/riepilogoArchivio.csv')
# df = df.dropna()
df['numero'] = df['CASI TOTALI']
df.sample(5)
# -

# Prendiamo in esame i malati cumulativi in base ai giorni.

# +
# semplifichiamo le date usando il giorno dell'anno ( da 0 a 365 )
df['tempo'] = df['datetime'].map( lambda d: pd.to_datetime(d).timetuple().tm_yday )

# raggruppa in base al giorno
df_by_datetime = df[ ['datetime', 'tempo', 'numero'] ].groupby('tempo')
df_by_datetime = df_by_datetime.sum().sort_values(by='tempo')
df_by_datetime = df_by_datetime.reset_index()

# contagi cumulativi
g = sns.scatterplot(data=df_by_datetime, x='tempo', y='numero')
g.set_title('Andamento numero contagiati (cumulativo)')
plt.show()


# -

# Definiamo quattro modelli diversi
# - linea
# - potenza
# - esponente
# - sigmoide

# +
def line(x, a, b, c):
    return x*a + b
line_init_params = { 'a': 2, 'b': 1, 'c':0 }

def power(x, a, b, c):
    return (x**a) * b + c
pow_init_params = { 'a': 2, 'b': 1, 'c':0 }

def exponent(x, a, b, c):
    return (a**x) * b + c
exp_init_params = { 'a': 2, 'b': 10, 'c':0 }

def sigmoid(x, a, b, c):
    expo = a * (b - x)
    sig = 1 / ( 1 + np.exp( expo ) ) * c
    return sig
sig_init_params = { 'a': 0.001, 'b': 500, 'c':4000 }

all_models_and_initial_params = [
    ['lineare', line, line_init_params],
    ['potenza', power, pow_init_params],
    ['esponenziale', exponent, exp_init_params],
    ['sigmoidale', sigmoid, sig_init_params]
]

# +
df_x = df_by_datetime['tempo'].values
df_y = df_by_datetime['numero'].values

for mod_name, mod, init_params in all_models_and_initial_params:
    
    model  = Model(mod)
    result = model.fit( df_y, x=df_x, **init_params)
    
    all_year = np.linspace(np.min(df_x), np.max(df_x)*1.2)
    predictions = result.eval(x=all_year)
    plt.plot(all_year, predictions, label=mod_name)
    # print(result.fit_report())   # decommenta questa linea per ottenere le metriche

plt.plot(df_x, df_y, 'o', label='osservazioni')
plt.legend(loc='best')
plt.show()
