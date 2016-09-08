# -*- coding: utf-8 -*-
"""
Created on Mon Aug 22 01:14:13 2016

@author: Fede
"""

from clases_tesis import Persona,Sociedad,crear_sociedad
import numpy as np
import matplotlib.pyplot as plt


def grafico_de_fases(cantidad_de_personas,numero_de_vecinos):
    Ct = 5
    Cmax = 10 
    k = 2
    n_max = 1000000
    
    d = 1000
    RV = np.zeros([d,d])    
    
    
    for i,P0 in enumerate(np.linspace(0,1,d)):
        for j,delta in enumerate(np.linspace(0,1,d)):
            s = crear_sociedad(cantidad_de_personas,numero_de_vecinos,P0,Ct,Cmax,delta)
            s.iterar(delta,k,Ct,n_max)
            RV[i,j] = s.convergio()[1]         
            
            
    print(RV)
    plt.matshow(RV)
    plt.xlabel('P0')
    plt.ylabel('delta')
    plt.axis([0, d-1, 0, d-1])
    plt.show()
    print("rojo: Tbp, Amarillo: T+T-, Celeste: T0, Azul: no convergio")
grafico_de_fases(100,500)











