with open("kernel.bin", "rb") as f:
    counter = 0
    print()
    instr = f.read(2)
    while instr != b"":
        print(counter, end="\t")
        print("{0:08b}".format(instr[1]) + " {0:08b}".format(instr[0]))
        counter += 2
        f.read(2)
        instr = f.read(2)