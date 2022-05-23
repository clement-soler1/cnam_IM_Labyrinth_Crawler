import cv2
import mediapipe as mp
import numpy as np
import screeninfo
import keyboard


# function to allow to close cv2 window by getting out of the while loop
def leave():
    global started
    started = False


keyboard.on_press_key("p", lambda _:leave())

CAMERA_NUMBER = 0

screen = screeninfo.get_monitors()[0]
width, height = screen.width, screen.height
dim = (width, height)
started = True


# get the bounding box of a detected hand
def getHandBoundingBox(handLms):
    bbox = dict()
    bbox["minX"] = float("inf")
    bbox["minY"] = float("inf")
    bbox["maxX"] = 0
    bbox["maxY"] = 0
    for landmark in handLms.landmark:
        if landmark.x < bbox["minX"]:
            bbox["minX"] = landmark.x
        if landmark.x > bbox["maxX"]:
            bbox["maxX"] = landmark.x
        if landmark.y < bbox["minY"]:
            bbox["minY"] = landmark.y
        if landmark.y > bbox["maxY"]:
            bbox["maxY"] = landmark.y
    return bbox


# function to start the program to track the hand
def start():
    global started
    started = True

    cap = cv2.VideoCapture(CAMERA_NUMBER)
    # handle if camera number doesn't correspond to a camera
    if not cap.isOpened():
        print("Cannot open camera")
        exit()

    # initialize hand detection with mediapipe
    mpHands = mp.solutions.hands
    hands = mpHands.Hands(static_image_mode=False,
                          max_num_hands=1,
                          min_detection_confidence=0.7,
                          min_tracking_confidence=0.7)

    bbox = dict()

    # main loop
    while True and started:
        success, img = cap.read()
        map_base = cv2.imread("data/map.png")
        game_map = cv2.resize(map_base, dim, interpolation=cv2.INTER_AREA)
        result_img = np.zeros_like(game_map)
        imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        results = hands.process(imgRGB)
        if results.multi_hand_landmarks:
            for handLms in results.multi_hand_landmarks:
                bbox = getHandBoundingBox(handLms)
                h, w, c = game_map.shape

                box_center = (w - round(((bbox["minX"] * w) + (bbox["maxX"] * w))/2),
                              round(((bbox["minY"] * h) + (bbox["maxY"] * h)) / 2))

                # image processing
                # draw filled circle in white on black background as mask
                mask = np.zeros_like(game_map)
                mask = cv2.circle(mask, box_center, 200, (255, 255, 255), -1)

                # apply mask to image
                result_img = cv2.bitwise_and(game_map, mask)

        # draw the window
        cv2.namedWindow("window", cv2.WND_PROP_FULLSCREEN)
        cv2.setWindowProperty("window", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
        cv2.imshow("window", result_img)
        cv2.waitKey(1)

    # close the cv2 window
    cv2.destroyAllWindows()
    cv2.waitKey(1)
