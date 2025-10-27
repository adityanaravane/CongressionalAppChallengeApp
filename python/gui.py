from mlRunner import mlRunner
import customtkinter as ctk
from genericframe import genericframe

class App(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("Heart disease prediction app")
        self.geometry("1024x768")
        ctk.set_appearance_mode("System")
        ctk.set_default_color_theme("blue")

        self.titleWidget = ctk.CTkLabel(self, text="Heart Disease Prediction", font=("Arial", 25))
        self.titleWidget.grid(row=0, column=0, padx=5, pady=5)

        self.ioframe = genericframe(self)
        self.ioframe.grid(row=1, column = 0)

        self.ioframe.createnninputframe()
        self.ioframe.creatennoutputframe()

    def animateHeart(self, indx):
        self.ioframe.animateHeart(indx)

if __name__ == "__main__":
    app = App()
    app.after(500, app.animateHeart, 0)
    app.mainloop()
