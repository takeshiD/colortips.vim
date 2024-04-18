if __name__ == '__main__':
    cc = "#ff0000 #00ff00 #0000ff\n#f00 #0f0 #00f\nrgb(255,0,0) rgb(0,255,0) rgb(0,0,255)\nrgba(255,0,0,0.5) rgba(0,255,0,0.5) rgba(0,0,255,0.5)\n"
    with open('performance.txt', 'w') as f:
        for i in range(1000):
            f.write(cc)

