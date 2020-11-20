#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 22 14:07:36 2018

@author: heshamelshafei
"""

# !pip install tensorpac

from visbrain import Brain
from visbrain.objects import SourceObj, BrainObj
import numpy as np
import scipy.io as sio

mat_name        = '/Volumes/dycog/Aurelie/DATA/MEG/PAT_EXPE22/data_fieldtrip/source_for_python.mat'

data_pow        = np.array(np.array(sio.loadmat(mat_name)['source']['pow'][0])[0])
data_xyz        = np.array(np.array(sio.loadmat(mat_name)['source']['pos'][0])[0])
data_ins        = np.array(np.array(sio.loadmat(mat_name)['source']['inside'][0])[0])

#data_xyz        = data_xyz * 10

#data_pow        = data_pow[0:100]
#data_xyz        = data_xyz[0:100]
#data_ins        = data_ins[0:100]

subjects        = np.empty([len(data_pow)],dtype=str)

for i in range(0,len(data_pow)):
    subjects[i,] = '1'

kwargs = {}

u_color = ["#9b59b6","#9b59b6"]
kwargs['color'] = [u_color[int(k[0])] for k in subjects]
kwargs['alpha'] = 0.7

#kwargs['data'] = data_pow

kwargs['data'] = np.arange(len(subjects))


kwargs['radius_min']    = 2               # Minimum radius
kwargs['radius_max']    = 15              # Maximum radius
kwargs['edge_color']    = (1, 1, 1, 0.5)  # Color of the edges
kwargs['edge_width']    = .5              # Width of the edges
kwargs['symbol']        = 'square'            # Source's symbol

mask                    = np.equal(data_ins,1)
kwargs['mask']          = mask
kwargs['mask_color']    = 'gray'

#kwargs['text'] = subjects              # Name of the subject
#kwargs['text_color'] = "#f39c12"       # Set to yellow the text color
#kwargs['text_size'] = 1.5              # Size of the text
#kwargs['text_translate'] = (1.5, 1.5, 0)
#kwargs['text_bold'] = True

s_obj = SourceObj('SourceExample', data_xyz, **kwargs)
cb_kw = dict(cblabel="Project source activity", cbtxtsz=3., border=False, )

b_obj = BrainObj('B3', **cb_kw)
b_obj.project_sources(s_obj, cmap='viridis', vmin=0., under='orange',
                      vmax=550., over='darkred')

vb = Brain(source_obj=s_obj, brain_obj=b_obj)
vb.show()