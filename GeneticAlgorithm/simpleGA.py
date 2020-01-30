#!/usr/bin/python3

'''
title:            simpleGA
description:      A simple genetic algorithm 
author:           Alvaro Garcia Lopez (aka algalopez)
email:            algalopez85@gmail.com
version:          0.1
date:             5-April-2016

execution:        ./simpleGA_test.py

process:
                  1.- Generate random population
                  2.- Evaluate population
                  3.- Select breeding individuals
                  4.- Cross individuals to generate children
                  5.- Mutate children
                  6.- Evaluate children
                  7.- Reduce population and children into population
                  8.- Get statistics
                  9.- STOP?
                  
configuration:
                  geneType:            'Z': Integer, 'R': Real, C: Set element
                  geneMin:             Min value
                  geneMax:             Max value
                  geneChoice:          Set from where to choose a gene, ex: "0123456789abcdef"
                  chromosomeMin:       Min number of genes in a chromosome
                  chromosomeMax:       Max number of genes in a chromosome
                  populationMin:       Min number of chromosomes in population
                  populationMax:       Max number of chromosomes in population
                  selectionType:       {roulette_wheel, truncation, rank}
                  crossoverType:       {onepoint, twopoint}
                  crossoverMin:        Min number of crossovers
                  crossoverMax:        Max number of crossovers
                  mutationType:        {flipbit, boundary, uniform}
                  mutationGeneRate:    Mutation probability of every gene, ex: 0.1 is 10%
                  reductionType:       {surlvivalChildren, roulette}
                  evaluationType:      {chromosome, population, individual}
                  evaluationFunction:  Function from other file
                  stopType:            {generation, fitness, time}
                  stopValue:           Number of generations or fitness

styles: 
                  classes: OneOther
                  methods: one_other
                  variables: oneOther

'''

import random           # randint - uniform - choice
import logging          # Unused
import functools        # for testing with reduce function only






# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# ERRORS
# ------------------------------------------------------------------------------------------------------------

class CustomException(Exception):
   ''' For unimplemented stuff '''
   def __init__(self, valor):
      self.valor = valor
   def __str__(self):
      return repr(self.valor)

# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# GENERATORS
# ------------------------------------------------------------------------------------------------------------

def gene_generator(geneType, geneMin, geneMax, geneChoice, **rest):
   '''   generates new random gene g /
            geneMin <= gene <= geneMax ^
            types: 'Z': Integer, 'R': Real, 'C': elemenent from a list
   '''
   while True:
      if (geneType == 'Z'):
         yield random.randint(geneMin,geneMax)
      elif (geneType == 'R'):
         yield random.uniform(geneMin,geneMax)
      elif (geneType == 'C'):
         yield random.choice(geneChoice)
      else:
         raise CustomException("geneType not implemented")


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# INITIALIZATION
# ------------------------------------------------------------------------------------------------------------

def initialization(population, populationMin, populationMax, 
                          chromosomeMin, chromosomeMax, **rest): 
   '''   Creates first random population /
            populationMin <= len(population) <= populationMax ^
            chromosomeMin <= len(chromosome) <= chromosomeMax
   '''
   gg = gene_generator(**rest)
   
   populationSize = random.randint(populationMin, populationMax)
   chromosomeSize = random.randint(chromosomeMin, chromosomeMax)
   
   for j in range (populationSize):
      new_chromosome = list()
      for k in range (chromosomeSize):
         gene = next(gg)
         new_chromosome.append(gene)
      population.append(dict([('chromosome', new_chromosome),('fitness', 0)]))


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# EVALUATION
# ------------------------------------------------------------------------------------------------------------

def evaluation(population, evaluationType, **rest):
   '''   Evaluate chromosome's fitness based on evaluationType
            evaluationType E {chromosome, population, individual}
   '''
   if (evaluationType == "chromosome"):
      evaluation_chromosome(population, **rest)
   elif (evaluationType == "population"):
      evaluation_population(population, **rest)
   elif (evaluationType == "individual"):
      evaluation_individual(population, **rest)
   elif (evaluationType == "test"):
      evaluation_test(population, **rest)
   else:
      raise CustomException("EvaluationType not implemented")


def evaluation_test(population, **rest):
   '''   For test or template '''
   for individual in population:
      individual["fitness"] = functools.reduce(lambda x, y: 2*x+y, individual["chromosome"])


def evaluation_chromosome(population, evaluationFunction, **rest):
   for individual in population:
      individual["fitness"] = evaluationFunction(individual["chromosome"])


def evaluation_population(population, evaluationFunction, **rest):
   evaluationFunction(population)


def evaluation_individual(population, evaluationFunction, **rest):
   for individual in population:
      evaluationFunction(individual)


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# SELECTION
# ------------------------------------------------------------------------------------------------------------

def selection_generator(population, selectionType, **rest):
   '''   Generates chromosomes for reproduction based on selectionType 
            selectionType E {roulette_wheel, truncation, rank}
   '''
   if (selectionType == "roulette"):
      return selection_roulette(population, **rest)
   else:
      raise CustomException("selectionType not implemented")


def selection_roulette(population, **rest):
   ''' Selects individuals giving more probability for those with better fitness'''
   fitnessSum = sum(individual["fitness"] for individual in population)

   while True:
      randomVal = random.uniform(0, 1)
      partialSum = 0
      for individual in population:
         partialSum += (individual["fitness"] / fitnessSum)
         if (partialSum >= randomVal):
            yield individual
            break
            
            
# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# CROSSOVER
# ------------------------------------------------------------------------------------------------------------

def crossover(population, children, crossoverType, **rest):
   '''   Cross chromosomes to breed
            crossoverType E {onepoint, twopoint}
   '''
   if (crossoverType == 'onepoint'):
      crossover_onepoint(population, children, **rest)   
   elif (crossoverType == 'twopoint'):
      crossover_twopoint(population, children, **rest)
   else:
      raise CustomException("crossoverType not implemented")


def crossover_onepoint(population, children, selectionType, crossoverMin, crossoverMax, **rest):
   rg = selection_generator(population, selectionType)
   crossTimes = random.randint(crossoverMin, crossoverMax)
   
   for times in range (crossTimes):
   
      ch1 = next(rg)
      ch2 = next(rg)
      
      pointMax = min(len(ch1["chromosome"]), len(ch2["chromosome"]))
      point = random.randint(0, pointMax)

      baby1 = {"chromosome":list(), "fitness":0}
      baby2 = {"chromosome":list(), "fitness":0}
      baby1["chromosome"] = ch1["chromosome"][:point]+ch2["chromosome"][point:]
      baby2["chromosome"] = ch2["chromosome"][:point]+ch1["chromosome"][point:]

      children.append(baby1)
      children.append(baby2)


def crossover_twopoint(population, children, selectionType, crossoverMin, crossoverMax, **rest):
   # TODO:
   raise CustomException("crossoverType not implemented")


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# MUTATION
# ------------------------------------------------------------------------------------------------------------

'''
   Options:
      chromosome mutation rate + gene mutation rate
      only chromosome mutation rate p, and mutate 1 gene randomly
      only gene mutation rate <----------------------------------------------------
'''

def mutation(children, mutationType, **rest):
   '''   Muatate generated children
         mutationType E {flipbit, boundary, uniform}
   '''
   if (mutationType == 'flipbit'):
      mutation_flipbit(children, **rest)
   elif(mutationType == 'boundary'):
      mutation_boundary(children, **rest)
   elif(mutationType == 'uniform'):
      mutation_uniform(children, **rest)
   else:
      raise CustomException("mutationType not implemented")


def mutation_flipbit(children, mutationGeneRate, geneType, geneMin, geneMax, geneChoice, **rest):
   ''' Inverts the bits of a gene '''
   # TODO
   raise CustomException("mutationType not implemented")


def mutation_boundary(children, mutationGeneRate, geneType, geneMin, geneMax, geneChoice, **rest):
   ''' Chooses a boundary value randomly '''
   # TODO
   raise CustomException("mutationType not implemented")

   
def mutation_uniform(children, mutationGeneRate, geneType, geneMin, geneMax, geneChoice, **rest):
   ''' Chooses a random value between boundaries '''
   gg = gene_generator(geneType, geneMin, geneMax, geneChoice)
   
   for individual in children:
      for i, gene in enumerate(individual["chromosome"]): # Use enumerate to mutate gene outofscope
         randomVal = random.uniform(0,1) # PUUFFF
         if (randomVal < mutationGeneRate):
            individual["chromosome"][i] = next(gg)


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# REDUCTION
# ------------------------------------------------------------------------------------------------------------

def reduction(population, children, reductionType, **rest):
   '''   Reduce population and children to the next population generation 
            reductionType E {surlvivalChildren, roulette}
   '''
   if (reductionType == "survivalChildren"):
      reduction_survivalChildren(population, children, **rest)
   elif (reductionType == "roulette"):
      reduction_roulette(population, children, **rest)
   else:
      raise CustomException("reductionType not implemented")


def reduction_survivalChildren(population, children, populationMax, populationMin, **rest):
   '''   Only children survives '''
   population[:] = children

   while (len(population) > populationMax):
      # TODO: 
      pass
   
   while (len(population) < populationMin):
      # TODO: 
      pass
      
      
def reduction_roulette(population, children, populationMin, populationMax, **rest):
   '''   Chooses by roulette alternating half from population and half children '''
   
   populationGenerator = selection_generator(population, selectionType = "roulette")
   childrenGenerator = selection_generator(children, selectionType = "roulette")
   
   new_population = []
   
   newPopulationSize = random.randint(populationMin, populationMax)
   
   while len(new_population) < newPopulationSize:
      new_population.append(next(populationGenerator))
      if (len(new_population) < newPopulationSize):
         new_population.append(next(childrenGenerator))
   
   population[:] = new_population


# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# STOP
# ------------------------------------------------------------------------------------------------------------

def stop(population, actualGeneration, stopType, stopValue, **rest):
   '''   Stops algorithm when in run mode 
            stopType E {generation}
   '''
   if (stopType == "generation"):
      stop_generation(actualGeneration, stopValue)
   if (stopType == "fitness"):
      stop_fitness(population, stopValue)
   if (stopType == "time"):
      stop_time(population, stopValue)
   else:
      raise CustomException("stopType not implemented")


def stop_generation(actualGeneration, stopValue):
   '''   Stops when a number of generations is reached '''
   
   if (actualGeneration >= stopValue):
      return True
   else:
      return False


def stop_fitness(population, stopValue):
   '''   Stops when a fitness value is reached '''
   # TODO
   raise CustomException("stopType not implemented")


def stop_time(population, stopValue):
   '''   Stops when a fitness value is reached '''
   # TODO
   raise CustomException("stopType not implemented")

# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# SORT AND STATISTICS
# ------------------------------------------------------------------------------------------------------------

def mean(population):
   ''' Arithmetic mean (mu): Sum of all fitnesses divided by the number of individuals '''
   avg = sum(individual["fitness"] for individual in population) / len(population)
   return avg


def average(population):
   ''' Arithmetic mean (mu): Sum of all fitnesses divided by the number of individuals '''
   avg = sum(individual["fitness"] for individual in population) / len(population)
   return avg
   

def variance(population, decimals= 4, mean=0):
   ''' Variance = sigma2 = (1/n) * Sum(xi - X) '''
   if (mean == 0):
      mean = sum(individual["fitness"] for individual in population) / len(population)
      
   sumDeviation = sum((individual["fitness"] - mean) for individual in population) / len(population)
   sigma2 = (1/len(population)) * (sumDeviation**2)
   return round(sigma2, decimals)


def sort_population(population):
   ''' Sort population for later selection '''
   population[:] = sorted(population, key = lambda k: k['fitness'], reverse=True)
   
# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# ALGORITM CLASS
# ------------------------------------------------------------------------------------------------------------

class Algorithm(object):

   # Default configuration
   config = {  "test": 5,
               "populationMin": 6, "populationMax": 6, 
               "chromosomeMin": 6, "chromosomeMax": 6,
               "geneType": 'Z', "geneMin": 0, "geneMax": 9, "geneChoice": "0123456789abcdef",
               "selectionType": "roulette", 
               "crossoverType": 'onepoint', "crossoverMin": 3, "crossoverMax": 3,
               "mutationType": 'uniform', "mutationGeneRate": 0.1, 
               "reductionType": "survivalChildren", "populationMin": 6, "populationMax": 6,
               "evaluationType": "population", "evaluationFunction":"evaluation_test",
               "stopType": "generation", "stopValue": 100}
   
   population = list()
   children = list()
   
   generationNumber = 0
   bestIndividual = dict()
   
   def __init__(self, config):
      
      for key in config:
         if key in self.config:
            self.config[key] = config[key]
   
   def initialize(self):
      self.generationNumber = 1
      initialization(self.population, **self.config)
      evaluation(self.population, **self.config)
      sort_population(self.population)
      self.bestIndividual = self.population[0]

   def step(self):

      # 1.- Cross population
      crossover(self.population, self.children, **self.config)
      
      # 2.- Mutate children
      mutation(self.children, **self.config)
     
      # 3.- Evaluate children
      evaluation(self.children, **self.config)
      sort_population(self.children)
      
      # 4.- Reduce population and children into population
      reduction(self.population, self.children, **self.config)
      sort_population(self.population)

      self.children = list()
      
      # 5.- Get statistics
      if (self.population[0]["fitness"] > self.bestIndividual["fitness"]): 
         self.bestIndividual = self.population[0]
      
      self.generationNumber += 1
      
      # 6.- STOP?
         # Only when running
      
   def run(self):
      # TODO
      raise CustomException("run method not implemented")

   def get_population(self):
      return (self.population)
      
   def get_statistics(self):
      generation = self.generationNumber
      mean = average(self.population)
      max_ = self.population[0]["fitness"]
      min_ = self.population[-1]["fitness"]
      sigma2 = variance(self.population, mean=mean)
      
      return {"generation": generation, "max": max_, "min": min_, "mean":mean, "variance":sigma2}

   def get_bestIndividual(self):
      return self.bestIndividual

# ------------------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------------------
# START AND LOGS
# ------------------------------------------------------------------------------------------------------------


logging.basicConfig(level = logging.DEBUG, format="%(asctime)s: %(levelname)-8s > %(message)s", datefmt="%I:%M:%S")
if __name__ == '__main__':
   logging.debug('starting as program')
else:
   logging.debug('starting as library')




