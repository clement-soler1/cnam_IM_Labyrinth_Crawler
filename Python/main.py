from tkinter import *
import screeninfo
import getHandPosition as gameScene
from PIL import Image,ImageTk

####################################
NAME = "Ouroboros : Labyrinth Crawler - GM client"
VERSION = "1.0 - Prod"
####################################


screen = screeninfo.get_monitors()[0]
width, height = screen.width, screen.height
dim = (width, height)

root = Tk()
root.title("Labyrinth Crawler - GM client")
root.geometry(str(width - 100) + "x" + str(height - 100))

# background
bg = Image.open("data/bg.png")
resized_bg = bg.resize((width+2, height), Image.ANTIALIAS)
new_bg = ImageTk.PhotoImage(resized_bg)
label_bg = Label(root, image=new_bg)
label_bg.place(x=-2, y=0)

# trick to have the button in pixel size
pixel = PhotoImage(width=1, height=1)

# Button 1 - Nouvelle Partie
Button(root, text="Nouvelle Partie", command=gameScene.start, image=pixel, height=50, width=200, compound="c").place(
    relx=(0.5 - 100 / width),
    rely=(0.5 - 25 / height))

# Button 2 - Crédits
Button(root, text="Crédits", image=pixel, height=50, width=200, compound="c", state=DISABLED).place(
    relx=(0.5 - 100/width),
    rely=(0.6 - 25 / height))

# Button 3 - Quitter
Button(root, text="Quitter", command=root.destroy, image=pixel, height=50, width=200, compound="c").place(
    relx=(0.5 - 100/width),
    rely=(0.7 - 25/height))

# version label
version_str = StringVar()
version_label = Label(root, textvariable=version_str, font=('Arial', 12), fg="white", bg="black")
version_str.set(NAME + " | " + VERSION)
version_label.place(
    relx=10/width,
    rely=1 - (40/height))

root.mainloop()
