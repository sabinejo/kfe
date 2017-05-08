import glob
import pandas as pd
import numpy as np


#for month_file in glob.glob('Data/*'):
test_file = "Data/gdelt_20140101_20140131.csv"
df = pd.read_csv(test_file, header=0, dtype=str,
                               index_col=False)
print df.shape[0]
#df = df.head(1000)

# max eventid for each url 
gdelt_max_id = df.groupby('SOURCEURL')['GLOBALEVENTID'].max()

# keep only max ids to remove duplicates
df = df[df['GLOBALEVENTID'].isin(gdelt_max_id)]

# create columns for protest, material conflict, rebellion, radicalism

df['protest'] = np.where(df['EventRootCode']=='14', 1, 0)
df['material_conflict'] = np.where(df["QuadClass"]=='4', 1, 0)
df['rebellion'] = np.where(df["Actor1Type1Code"].isin(["REB","SEP","INS"]), 1, 0)
df['radicalism'] = np.where(np.logical_or.reduce((df["Actor1Type1Code"]=='RAD',df["Actor1Type2Code"]=='RAD',df["Actor1Type3Code"]=='RAD')),1, 0)
df['GoldsteinScale'] = df['GoldsteinScale'].apply(lambda x : float(x))

# create aggregates

aggregations = {
	'protest' : {'protest_events': 'sum'},
	'material_conflict' : {'material_conflict_events': 'sum'},
	'rebellion' : {'rebellion_events': 'sum'},
	'radicalism' : {'radicalism_events': 'sum'},
	'GoldsteinScale' : {
	'gs_median': 'median',
	'gs_min': lambda x: min(x),
	'gs_max': lambda x: max(x)
	},
}

#print df.groupby(['MonthYear','ActionGeo_Lat','ActionGeo_Long']).agg(aggregations)



