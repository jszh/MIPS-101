with open("C:\\Users\\Jason\\Desktop\\cpu-memory dump\\ext-0000-32010.bin", "rb") as f1:
    counter = 0
    print()
    mem = f1.read(4)
    while mem != b"":
        if counter >= 32768 and counter <= 32780:
            print(counter, end="\t")
            print("{0:08b}".format(mem[3]) + " {0:08b}".format(mem[2]) + "; {0:08b}".format(mem[1]) + " {0:08b}".format(mem[0]))
        counter += 1
        mem = f1.read(4)