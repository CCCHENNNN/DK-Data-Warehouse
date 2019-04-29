import numpy as np
from pandas import DataFrame, read_csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd


headers = ["departement","nb_villes"]
data = pd.read_csv("nbville.csv", names=headers)
data.set_index("departement", inplace= True)
ax=data.plot(
          kind='bar',
          )
          
ax.set_xticks(np.arange(start=0, stop=99, step=5))
ax.set_xticklabels(np.arange(start=0, stop=99, step=5))
# otherwise too many labels on x_axis
#plt.xticks(fontsize=4, rotation= 60 )
plt.savefig('resultat.pdf')