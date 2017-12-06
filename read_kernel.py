with open("C:\\Users\\Jason\\Desktop\\cpu-memory dump\\ext-0000-900-4.bin", "rb") as f1, open("kernel.bin", "rb") as f2:
    counter = 0
    print()
    mem = f1.read(4)
    instr = f2.read(4)
    while instr != b"" and mem != b"":
        counter += 1
        if (mem[0:1] != instr[0:1]):
            print(counter, end="\t")
            print("{0:08b}".format(mem[1]) + " {0:08b}".format(mem[0]) + "; {0:08b}".format(instr[1]) + " {0:08b}".format(instr[0]))
        
        mem = f1.read(4)
        instr = f2.read(4)