import csv
aircraftTypes = []
with open('store_aircraftTypes.csv', 'r', newline='', encoding='utf-8') as file:
    lines = file.readlines()
    for at in lines:
        aircraftTypes.append(at)

uniqueTailNums = []
with open("unique_TailNo.csv", "r", encoding="utf-8") as file:
    lines = file.readlines()
    for tailnum in lines:
        uniqueTailNums.append(tailnum)

with open("tailNumxAircraftType.csv", "w", encoding='utf-8') as file:
    for tup in zip(uniqueTailNums,aircraftTypes):
        file.write(tup[0].strip())
        file.write(',')
        file.write(tup[1].strip())
        file.write('\n')

print(len(aircraftTypes))
