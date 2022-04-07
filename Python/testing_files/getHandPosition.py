import json
import cv2
import mediapipe as mp
import numpy as np
import screeninfo


CAMERA_NUMBER = 0

screen = screeninfo.get_monitors()[0]
width, height = screen.width, screen.height
dim = (width, height)


def getHandBoundingBox(landmarks):
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
    imgRGB = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    results = hands.process(imgRGB)
    # print(results.multi_hand_landmarks)
    if results.multi_hand_landmarks:
        for handLms in results.multi_hand_landmarks:
            for id, lm in enumerate(handLms.landmark):
                # print(id,lm)
                h, w, c = img.shape
                cx, cy = int(lm.x *w), int(lm.y*h)
                # if id ==0:
                cv2.circle(img, (cx,cy), 3, (255,0,255), cv2.FILLED)

            mpDraw.draw_landmarks(img, handLms, mpHands.HAND_CONNECTIONS)
            bbox = getHandBoundingBox(handLms)
            h, w, c = game_map.shape
            pt1 = (round(bbox["maxX"] * w), round(bbox["minY"] * h))
            pt2 = (round(bbox["minX"] * w), round(bbox["maxY"] * h))
            # cv2.rectangle(map, pt1, pt2, (0, 255, 0))

            box_center = (w - round(((bbox["minX"] * w) + (bbox["maxX"] * w))/2),
                          round(((bbox["minY"] * h) + (bbox["maxY"] * h)) / 2))
            cv2.circle(game_map, box_center, 50, (0, 255, 0))

            bbox["center"] = [(bbox["minX"] + bbox["maxX"])/2, (bbox["minY"] + bbox["maxY"])/2]

    # cTime = time.time()
    # fps = 1/(cTime-pTime)
    # pTime = cTime

    # cv2.putText(map,str(int(fps)), (10,70), cv2.FONT_HERSHEY_PLAIN, 3, (255,0,255), 3)

    # appliquage filtre noir

    # print(map.shape)
    # print(bbox)
    shower = np.zeros(game_map.shape)

    # if bbox:
    #     minX_pix = round(bbox["minX"] * width)
    #     maxX_pix = round(bbox["maxX"] * width)
    #     minY_pix = round(bbox["minY"] * height)
    #     maxY_pix = round(bbox["maxY"] * height)
    #     # for x in range(height):
    #     #     for y in range(width):
    #     #         print(bbox)
    #     #         if not (x >= bbox["minX"] and x <= bbox["maxX"] and y >= bbox["minY"] and y <= bbox["maxY"]):
    #     #             map[x][y] = [0,0,0]
    #     for x in range(minX_pix, maxX_pix):
    #         for y in range(minY_pix, maxY_pix):
    #             shower[y][x] = game_map[y][x]

    #traitement de l'image

    # draw filled circle in white on black background as mask
    mask = np.zeros_like(img)
    mask = cv2.circle(mask, (xc, yc), radius, (255, 255, 255), -1)

    cv2.imshow("Image", game_map)
    # print(json.dumps(bbox))
    cv2.waitKey(1)
