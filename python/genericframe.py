import pandas as pd
import torch
from tkinter import *
from mlRunner import mlRunner
import customtkinter as ctk
from PIL import Image, ImageSequence
from hovertooltip import CreateToolTip
import tkinter
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from string import ascii_letters
import seaborn as sns
import matplotlib.pyplot as plt

class genericframe(ctk.CTkFrame):

    def __init__(self, *args, headername='frame', **kwargs):
        super().__init__(*args, **kwargs)
        self.dataColumns = ["age",'sex','cp','trestbps','chol','fbs','restecg','thalach','exang','oldpeak','slope','ca']

        self.tabview = ctk.CTkTabview(self, height=400, width=400, command=self.onChangeTab)
        self.tabview.pack(padx=5, pady=5)
        #self.tabview.grid_propagate(False)

        self.tabview.add("Neural Network")
        #self.tabview.add("Data")

        self.canvas = None
        self.data = None
        self.fig = None
        self.ax = None
        self.plot = None

        self.heartGIFs = []
        heartGIF = Image.open('heart.gif')
        for i in range(heartGIF.n_frames):
            imgName = "resources/heart_" + str(i+1) + ".png"
            self.heartGIFs.append(ctk.CTkImage(light_image=Image.open(imgName), dark_image=Image.open(imgName),
                                    size=(162, 180)))

    def createnninputframe(self):
        self.yoffset = 320
        self.xoffset = 40

        self.inputframe = ctk.CTkFrame(self.tabview.tab("Neural Network"), height=320, width=700, corner_radius=15)
        self.inputframe.grid_propagate(False)
        self.inputframe.grid(row=0, column=0, pady=5, padx=5)


        self.age = ctk.CTkEntry(self.inputframe)
        self.age.grid(row=1, column=1, pady=5, sticky=W)
        self.agelabel = ctk.CTkLabel(self.inputframe, text="age", font=("Arial", 20))
        self.agelabel.grid(row=1, column=0, padx=20, pady=15, sticky=W)  # place(x=self.xoffset, y=self.yoffset)

        self.sex = ctk.CTkOptionMenu(self.inputframe, values=['Male', 'Female'])  # CTkEntry(root)
        self.sex.grid(row=2, column=1, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 30)
        self.sexlabel = ctk.CTkLabel(self.inputframe, text="sex", font=("Arial", 20))
        self.sexlabel.grid(row=2, column=0, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 30)

        self.cp = ctk.CTkOptionMenu(self.inputframe, values=['typical angina', 'atypical angina', 'non-anginal pain',
                                                  'asymptomatic'])  # CTkEntry(self)
        self.cp.grid(row=1, column=4, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 60)
        self.cplabel = ctk.CTkLabel(self.inputframe, text="chest pain type", font=("Arial", 20))
        self.cplabel.grid(row=1, column=3, padx=15, pady=5, sticky=E)  # (x=self.xoffset, y=self.yoffset + 60)
        CreateToolTip(self.inputframe,
                      "Type of chest pain: \n Value 1: typical angina, \nValue 2: atypical angina, \nValue 3: non-anginal pain, \nValue 4: asymptomatic",
                      row=1, column=5, padx=8, pady=5)

        self.bps = ctk.CTkEntry(self.inputframe)
        self.bps.grid(row=2, column=4, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 90)
        self.bpslabel = ctk.CTkLabel(self.inputframe, text="bps at rest", font=("Arial", 20))
        self.bpslabel.grid(row=2, column=3, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 90)
        CreateToolTip(self.inputframe, "resting blood pressure (mm Hg)", row=2, column=5, padx=8,
                      pady=5)

        #cholestorol
        self.chol = ctk.CTkEntry(self.inputframe)
        self.chol.grid(row=3, column=4, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 120)
        self.chollabel = ctk.CTkLabel(self.inputframe, text="cholesterol", font=("Arial", 20))
        self.chollabel.grid(row=3, column=3, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 120)
        CreateToolTip(self.inputframe, "serum cholesterol (mg/dl)", row=3, column=5, padx=8,
                      pady=5)

        # fbs
        self.fbs = ctk.CTkCheckBox(self.inputframe, onvalue=1, offvalue=0,
                                   text='')  # CTkOptionMenu(root, values=["False", "True"])#ctk.CTkEntry(root)
        self.fbs.grid(row=3, column=1, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 150)
        self.fbslabel = ctk.CTkLabel(self.inputframe, text="fbs", font=("Arial", 20))
        self.fbslabel.grid(row=3, column=0, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 150)
        CreateToolTip(self.inputframe, "Is fasting blood sugar greater than 120 mg/dl?", row=3, column=2, padx=8,
                      pady=5)
        # restecg
        self.restcg = ctk.CTkOptionMenu(self.inputframe, values=["normal", "ST-T wave abnormal", "left ventricular hypertrophy"])#CTkEntry(self.inputframe)
        self.restcg.grid(row=4, column=1, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 180)
        self.restcglabel = ctk.CTkLabel(self.inputframe, text="rest ecg", font=("Arial", 20))
        self.restcglabel.grid(row=4, column=0, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 180)
        CreateToolTip(self.inputframe, "resting electro-cardiographic results", row=4, column=2, padx=8,
                      pady=5)

        # thalach
        self.thalach = ctk.CTkEntry(self.inputframe)
        self.thalach.grid(row=4, column=4, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 210)
        self.thalachlabel = ctk.CTkLabel(self.inputframe, text="max rate", font=("Arial", 20))
        self.thalachlabel.grid(row=4, column=3, padx=20, pady=5,
                               sticky=W)  # place(x=self.xoffset, y=self.yoffset + 210)
        CreateToolTip(self.inputframe, "maximum heart rate achieved", row=4, column=5, padx=8,
                      pady=5)

        # exang
        self.exang = ctk.CTkCheckBox(self.inputframe, onvalue=1, offvalue=0, text='')  # CTkEntry(root)
        self.exang.grid(row=5, column=1, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 240)
        self.exanglabel = ctk.CTkLabel(self.inputframe, text="angina", font=("Arial", 20))
        self.exanglabel.grid(row=5, column=0, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 240)
        CreateToolTip(self.inputframe, "Whether the patient has exercise induced angina \nAngina is chest pain due to reduced blood flow to heart", row=5, column=2, padx=8, pady=5)

        # oldpeak
        self.oldpeak = ctk.CTkEntry(self.inputframe)
        self.oldpeak.grid(row=5, column=4, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 270)
        self.oldpeaklabel = ctk.CTkLabel(self.inputframe, text="ST depression", font=("Arial", 20))
        self.oldpeaklabel.grid(row=5, column=3, padx=20, pady=5,
                               sticky=W)  # place(x=self.xoffset, y=self.yoffset + 270)
        CreateToolTip(self.inputframe, "The ST depression induced by exercise relative to rest", row=5, column=5, padx=8, pady=5)

        # slope
        #self.slope = ctk.CTkEntry(self.inputframe)
        self.slope = ctk.CTkOptionMenu(self.inputframe, values=['0', '1', '2'])  # CTkEntry(self)
        self.slope.grid(row=6, column=1, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 300)
        self.slopelabel = ctk.CTkLabel(self.inputframe, text="slope", font=("Arial", 20))
        self.slopelabel.grid(row=6, column=0, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 300)
        CreateToolTip(self.inputframe, "The ST segment shift relative to exercise-induced increments in heart rate", row=6,
                      column=2, padx=8, pady=5)
        # ca
        self.ca = ctk.CTkOptionMenu(self.inputframe, values=['0', '1', '2', '3']) #ctk.CTkEntry(self.inputframe)
        self.ca.grid(row=6, column=4, pady=5, sticky=W)  # place(x=self.xoffset + 100, y=self.yoffset + 330)
        self.calabel = ctk.CTkLabel(self.inputframe, text="major vessels", font=("Arial", 20))
        self.calabel.grid(row=6, column=3, padx=20, pady=5, sticky=W)  # place(x=self.xoffset, y=self.yoffset + 330)
        CreateToolTip(self.inputframe, "Number of major vessels seen by flourosopy. \nNormal person has 3 major vessels", row=6, column=5, padx=8, pady=5)

        self.B = ctk.CTkButton(self.inputframe, text='Enter', command=lambda: self.updateoutput())
        self.B.grid(row=7, column=3, padx=20, pady=5)#place(x=self.xoffset + 40, y=self.yoffset + 360)

    def getinputs(self):
        gpp = self.sex.get()
        fbsvar = self.fbs.get()
        cptype = self.cp.get()
        cg = self.restcg.get()
        mlp = mlRunner()
        if gpp == 'Male':
            gpp = 1
        if gpp == 'Female':
            gpp = 0

        if fbsvar == "False" or fbsvar == 0:
            fbsvar = 0
        if fbsvar == "True" or fbsvar == 1:
            fbsvar = 1

        if cptype == 'typical angina':
            cptype = 0
        if cptype == 'atypical angina':
            cptype = 1
        if cptype == 'non-anginal pain':
            cptype = 2
        if cptype == 'asymptomatic':
            cptype = 3


        if cg == "normal":
            cgnum=0
        if cg== 'ST-T wave abnormal':
            cgnum=1
        if cg== "left ventricular hypertrophy":
            cgnum=2
        try:
            tensor = torch.tensor([[float(self.age.get()), float(gpp), float(cptype), float(self.bps.get()), float(self.chol.get()),
                  float(fbsvar), float(cgnum), float(self.thalach.get()), float(self.exang.get()),
                  float(self.oldpeak.get()), float(self.slope.get()), float(self.ca.get())]], dtype=torch.float)

            return mlp.modelin(tensor)
        except:
            print("issue")
            #print(self.tensor)
            #exit(1)
            return "Please provide all values"

    def creatennoutputframe(self):
        self.outputframe = ctk.CTkFrame(self.tabview.tab("Neural Network"), corner_radius=15)
        self.outputframe.grid(row=0, column=1, pady=5, padx=5)

        self.outputl = ctk.CTkLabel(self.outputframe, text="Please provide all inputs", font=("Comic Sans", 20))
        self.outputl.grid(row=0, column=0, pady=5, padx=5)

        self.heartAnimation = ctk.CTkLabel(self.outputframe, text='', image=self.heartGIFs[0])
        self.heartAnimation.grid(row=1, column=0, pady=5, padx=5)

    def animateHeart(self, indx):
        if indx >= 0 and indx < len(self.heartGIFs):
            self.heartAnimation.configure(True, image=self.heartGIFs[indx])
            indx += 1
        else:
            indx = 0

        self.after(30, self.animateHeart, indx)

    def updateoutput(self):
        output = str(self.getinputs())

        if output == "tensor([0])":
            self.outputl.configure(text="Heart disease unlikely")
            print(output)
        elif output == "tensor([1])":
            self.outputl.configure(text="Heart disease likely")
            print(output)
        else:
            print(output)
            print("error")
            #exit(1)
            self.outputl.configure(text=output)

    def onChangeTab(self):
        self.updateoutputs()

    def updateX(self, indx):
        self.updateoutputs()

    def updateY(self, indx):
        self.updateoutputs()

    def updateoutputs(self):
        x = str(self.xinput.get())
        y = str(self.yinput.get())
        print(x, y)
        activeTab = self.tabview.get()
        if activeTab == 'Data':
            sns.set(style="white")
            if self.data is None:
                # Get data
                self.data = pd.read_csv("heart.csv")

            if self.fig is not None:
                plt.cla()
                plt.close(self.fig)

            # Set up the matplotlib figure
            self.fig, self.ax = plt.subplots(figsize=(7, 5))
            # Draw the dot plot
            # sns.stripplot(data=self.data, x=x, y=y, hue="target")
            heart_dis = self.data.eval("target == 1").rename("heart_disease")
            self.plot = sns.scatterplot(data=self.data, x=x, y=y, hue=heart_dis)
            # fig = createplot(x=x, y=y, self.data)

            if self.canvas is None:
                self.canvas = FigureCanvasTkAgg(self.fig, master=self.dataoutputframe)  # A tk.DrawingArea.
                self.canvas.get_tk_widget().pack()
                self.canvas.draw()
            else:
                self.canvas.figure = self.fig
                self.canvas.draw()
