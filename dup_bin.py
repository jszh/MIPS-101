with open("test.bin", "rb") as f1, open("test32.bin", "wb") as f2:
    counter = 0
    print()
    mem = f1.read(2)
    while mem != b"":
        if counter >= 0:
            print(counter, end="\t")
            f2.write(mem)
            f2.write(mem)
            print("{0:08b}".format(mem[1]) + " {0:08b}".format(mem[0]))
        counter += 1
        mem = f1.read(2)
