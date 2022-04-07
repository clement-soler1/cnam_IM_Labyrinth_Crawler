import cv2
import mediapipe as mp
import numpy as np
import screeninfo

CAMERA_NUMBER = 0

screen = screeninfo.get_monitors()[0]
width, height = screen.width, screen.height
dim = (width, height)


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


cap = cv2.VideoCapture(CAMERA_NUMBER)
if not cap.isOpened():
    print("Cannot open camera")
    exit()


mpHands = mp.solutions.hands
hands = mpHands.Hands(static_image_mode=False,
                      max_num_hands=1,
                      min_detection_confidence=0.7,
                      min_tracking_confidence=0.7)
mpDraw = mp.solutions.drawing_utils

pTime = 0
cTime = 0
bbox = dict()

while True:
    success, img = cap.read()
    map_base = cv2.imread("data/map.jpg")
    game_map = cv2.resize(map_base, dim, interpolation=cv2.INTER_AREA)
    result_img = np.zeros_like(game_map)
    imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    results = hands.process(imgRGB)
    if results.multi_hand_landmarks:
        for handLms in results.multi_hand_landmarks:
            bbox = getHandBoundingBox(handLms)
            h, w, c = game_map.shape
            pt1 = (round(bbox["maxX"] * w), round(bbox["minY"] * h))
            pt2 = (round(bbox["minX"] * w), round(bbox["maxY"] * h))

            box_center = (w - round(((bbox["minX"] * w) + (bbox["maxX"] * w))/2),
                          round(((bbox["minY"] * h) + (bbox["maxY"] * h)) / 2))
            cv2.circle(game_map, box_center, 100, (0, 255, 0))

            bbox["center"] = [(bbox["minX"] + bbox["maxX"])/2, (bbox["minY"] + bbox["maxY"])/2]

            # traitement de l'image
            # draw filled circle in white on black background as mask
            mask = np.zeros_like(game_map)
            mask = cv2.circle(mask, box_center, 100, (255, 255, 255), -1)

            # apply mask to image
            result_img = cv2.bitwise_and(game_map, mask)

    cv2.imshow("Image", result_img)
    cv2.waitKey(1)
