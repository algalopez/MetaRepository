#!/usr/bin/python3

'''
title:            simpleGA
description:      A simple genetic algorithm 
author:           Alvaro Garcia Lopez (aka algalopez)
email:            algalopez85@gmail.com
version:          0.1
date:             5-April-2016

Execution:        ./simpleGA_example.py
'''


import simpleGA
import functools



# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# EXAMPLE FITNESS FUNCTIONS FOR DIFFERENT evaluationType
# ------------------------------------------------------------------------------------------------------------


def fitness_chromosome(chromosome):
   return functools.reduce(lambda x, y: 2*x+y, chromosome)


def fitness_population(population):
   for individual in population:
      individual["fitness"] = functools.reduce(lambda x, y: 2*x+y, individual["chromosome"])
      
      
def fitness_individual(individual):
   individual["fitness"] = functools.reduce(lambda x, y: 2*x+y, individual["chromosome"])


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------------------------------------

# If a configuration element is not added, 
# Genetic algorithm will use the default value of that element
config = {  "populationMin": 6, "populationMax": 8, 
            "chromosomeMin": 6, "chromosomeMax": 6,
            "geneType": 'Z', "geneMin": 0, "geneMax": 9, "geneChoice": "0123456789abcdef",
            "crossoverType": 'onepoint', "crossoverMin": 3, "crossoverMax": 3,
            "mutationType": 'uniform', "mutationGeneRate": 0.1, 
            "reductionType": "roulette",
            "evaluationType": "chromosome", "evaluationFunction": fitness_chromosome,
            #"evaluationType": "population", "evaluationFunction": fitness_population,
            #"evaluationType": "individual", "evaluationFunction": fitness_individual,
            #"evaluationType": "test",
            "stopType": "generation", "stopValue":50}
   


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# PRINTING RESULTS
# ------------------------------------------------------------------------------------------------------------

def print_population(population):
   for individual in population:
      print("{} -> {}".format(individual["chromosome"], individual["fitness"]))


#print("{}: {:.8g}".format(stat, stats[stat]))
def print_statistics():
   stats = ga.get_statistics()
   top = ga.get_bestIndividual()
   pop = ga.get_population()
   
   print("G:", stats["generation"] , 
         " - size:", len(pop), 
         " - top:", top["fitness"], 
         " - max:", stats["max"], 
         " - min:", stats["min"], 
         " - mean:", round(stats["mean"], 3))


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# EXECUTING THE ALGORITHM
# ------------------------------------------------------------------------------------------------------------

ga = simpleGA.Algorithm(config)
ga.initialize()

print_statistics()

for j in range (5):
   ga.step()
   print_statistics()

print(ga.get_bestIndividual())
