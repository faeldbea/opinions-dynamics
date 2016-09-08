# -*- coding: utf-8 -*-
"""
Created on Fri Aug 19 16:21:15 2016

@author: Fede
"""
import numpy as np

class Persona:
    def __init__(self,persuation,opinion):    # -10<C<10   -1<O<1 discreto
        self.C = persuation
        self.O = opinion
        self.vecinos = []
        
    def actualizar_opinion(self,Ct):
        if   self.C > Ct:
            self.O = 1
            
        elif self.C < (-1)*Ct:
            self.O = -1
            
        else:
            self.O = 0
            
    def agregar_vecino(self,persona2):
        self.vecinos.append(persona2)
        
    def eliminar_vecino(self,persona2):
        self.vecinos.remove(persona2)
        
    def interactuar(self,persona2,k,delta,Ct):       
        if self.C > persona2.C:
            if self.O == persona2.O:
                self.C -= delta
                persona2.C += delta
            elif self.O == (-1)*persona2.O:
                self.C += delta
                persona2.C -= delta
            elif self.O == 1 and persona2.O == 0:
                self.C -= delta
                persona2.C += delta*k
            elif self.O == 0 and persona2.O == -1:
                self.C -= delta*k
                persona2.C += delta
        else:
            if self.O == persona2.O:
                self.C += delta
                persona2.C -= delta
            elif self.O == (-1)*persona2.O:
                self.C -= delta
                persona2.C += delta
            elif self.O == 0 and persona2.O == 1:
                self.C += delta*k
                persona2.C -= delta
            elif self.O == -1 and persona2.O == 0:
                self.C += delta
                persona2.C -= delta*k
                

        self.actualizar_opinion(Ct)
        persona2.actualizar_opinion(Ct)

        
class Sociedad:
    def __init__(self):
        self.personas = []
        self.cantidad_personas = 0
        
    def agregar_persona(self,persona):
        self.personas.append(persona)
        self.cantidad_personas +=1
    
    def iterar1(self,delta,k,Ct):          #delta = 1, k =2
        for persona in self.personas:
            for persona2 in persona.vecinos:
                persona.interactuar(persona2,k,delta,Ct)
                
    def iterar(self,delta,k,Ct,n_max):
        n = 0
        while n<n_max and not(self.convergio()[0]):
            n += 1
            self.iterar1(delta,k,Ct)
    
    def estado_de_opinion(self):
        cantidad1  = 0
        cantidad0  = 0
        cantidad_1 = 0
        for persona in self.personas:
            if persona.O == 1:
                cantidad1 += 1
            elif persona.O == 0:
                cantidad0 += 1
            else:
                cantidad_1 += 1
                
        cantidad1  = cantidad1  / self.cantidad_personas
        cantidad0  = cantidad0  / self.cantidad_personas
        cantidad_1 = cantidad_1 / self.cantidad_personas              
                
        return [cantidad1,cantidad0,cantidad_1]
    
    def convergio(self):
        con = False
        tipo_de_convergencia = 0
        [Tmas,Tcero,Tmenos] = self.estado_de_opinion()
        
        if Tmas == Tmenos == 0:
            con = True
            tipo_de_convergencia = 1     
        elif (Tcero == Tmenos == 0 or Tmas == Tcero == 0):
            con = True
            tipo_de_convergencia = 2
        elif Tcero == 0:
            con = True
            tipo_de_convergencia = 3
            
        return [con,tipo_de_convergencia]
        


        
def crear_sociedad(cantidad_de_personas,numero_de_vecinos,P0,Ct,Cmax,delta):
    s = Sociedad()
    
    cantidad_P0  = int(cantidad_de_personas * P0)
    cantidad_P1  = int((cantidad_de_personas - cantidad_P0)/2)
    cantidad_P_1 = cantidad_de_personas - cantidad_P0 - cantidad_P1
    
    for i in range(cantidad_P0):
        opinion_p = np.around(2*Ct*np.random.random() - Ct)
        p = Persona(opinion_p,0)
        s.agregar_persona(p)
    for i in range(cantidad_P1):
        opinion_p = np.around((Cmax-Ct)*np.random.random() + Ct)
        p = Persona(opinion_p,1)
        s.agregar_persona(p)
    for i in range(cantidad_P_1):
        opinion_p = np.around(((-1)*Ct+Cmax)*np.random.random() - Ct)
        p = Persona(opinion_p,-1)
        s.agregar_persona(p)    
       
   
    for i in range(numero_de_vecinos):
        j = int(np.random.random()*cantidad_de_personas)
        k = int(np.random.random()*cantidad_de_personas)
        
        if j != k:
            s.personas[j].agregar_vecino(s.personas[k])
            s.personas[k].agregar_vecino(s.personas[j])
    
    return s
    
    
    
    
    
    
    
    
    
    
    
    
    
