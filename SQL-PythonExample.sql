sp_configure 'external scripts enabled',1
RECONFIGURE WITH OVERRIDE



EXEC sp_execute_external_script @language = N'Python', @script = N'
import pandas as pd
import numpy as np
import re

newset = np.array(1,2,3,4,5)
print(newset)'