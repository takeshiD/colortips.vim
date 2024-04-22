#!/usr/bin/python3
def generate_largesize():
    cc = "#ff0000 #00ff00 #0000ff\n#f00 #0f0 #00f\nrgb(255,0,0) rgb(0,255,0) rgb(0,0,255)\nrgba(255,0,0,0.5) rgba(0,255,0,0.5) rgba(0,0,255,0.5)\n"
    with open('performance.txt', 'w') as f:
        for i in range(1000):
            f.write(cc)

def generate_12bitcolor(fname):
    txt = ""
    for cc in range(2<<12-1):
        txt += f"#{cc:03x}"
        if cc % 16 == 15:
            txt += "\n"
        else:
            txt += " "
    with open(fname, 'w') as f:
        f.write(txt)


if __name__ == '__main__':
    generate_12bitcolor("test_12bitcolor.txt")
