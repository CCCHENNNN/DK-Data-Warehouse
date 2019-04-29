import numpy as np
from pandas import DataFrame, read_csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns; 
sns.set()
import pandas as pd


headers = ['x','y','proba']
data = pd.read_csv("heatmap.csv", names=headers)
carte=data.pivot(index='y',columns='x')
carte.columns = carte.columns.droplevel(0)
ax = sns.heatmap(carte,cmap='RdYlGn_r', linewidths=0.5)
plt.savefig('heatmap.pdf')