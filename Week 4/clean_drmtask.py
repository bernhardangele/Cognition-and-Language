import sys
import re
import csv


if len(sys.argv) >= 2:
    filename = sys.argv[1]

    p = re.compile(r"\d*,[is]\d*,drmtask,\d,[\d\w]*,(\d*),[\d\w]*,\d,[,]*,(\w+),([\d\.]*),(\d),(\w*),([old,new,lure]+),([\w]*)")

    with open(filename) as fin:
        lines = fin.readlines()


    with open("drmtask_clean.csv", 'wb') as csvfile:
        writer = csv.writer(csvfile, delimiter = ',')
        writer.writerow(['trialnumber','givenResponse','reactionTime','correct','word','stimulusType','correctResponse'])
        for line in lines:
            m = re.match(p, line)
            if m is not None:
                writer.writerow(m.groups())
else:
    print("No filename specified.\n")
