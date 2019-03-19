import numpy as np
import cv2

class Segmenteur:
    def __init__(self):
        #self.img = cv2.imread('messi5.jpg',0)
        self.img = np.zeros((512,512,3), np.uint8)
        print("coucou")

    def draw_line(self):
        self.img=cv2.line(self.img,(0,0),(511,511),(255,0,0),5)

    def show_image(self):
        cv2.imshow('image',self.img)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

if __name__ == '__main__':
    seg = Segmenteur()
    seg.draw_line()
    seg.show_image()
