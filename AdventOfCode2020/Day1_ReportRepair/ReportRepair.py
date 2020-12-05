#!/usr/bin/env python3

YEAR = 2020

def read_input_from_file():
    inputFile = open('input', 'r') 
    lines = [int(line) for line in inputFile.readlines()]
    inputFile.close()
    return lines

def get_two_numbers(lines, sumValue):
    start = 0
    end = len(lines) - 1
    keep_iterating = True
    solution = False

    while(keep_iterating):
        if (start == end): 
            keep_iterating = False

        if lines[start] + lines[end] == sumValue:
            keep_iterating = False
            solution = True
        elif lines[start] + lines[end] < sumValue:
            start += 1
        else:
            end -= 1

    if (solution == False): 
        raise BaseException

    num1 = lines[start]
    num2 = lines[end]
    print('Solution = ' + str(num1) + ' * ' + str(num2) + ' = ' + str(num1 * num2))


def get_three_numbers(lines):
    keep_iterating = True
    solution = False

    while(keep_iterating):
        
        if (len(lines) < 3):
            keep_iterating = False
            continue
            

        first_element = lines[0]
        lines = lines[1:]

        try:
            get_two_numbers(lines, YEAR - first_element)
            print('For value: ', first_element, 'and list_size: ', len(lines))
            solution = True
        except:
            keep_iterating = True

    if (solution == False) :
        print('No solution found')


if __name__ == "__main__":
    lines = read_input_from_file()
    lines.sort()
    #get_two_numbers(lines, YEAR)
    get_three_numbers(lines)

