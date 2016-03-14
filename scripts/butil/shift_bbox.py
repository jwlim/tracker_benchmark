
def shift_init_BB(r, shiftType, imgH, imgW):

    center = [r[0]+r[2]/2.0, r[1]+r[3]/2.0]

    br_x = r[0] + r[2] - 1
    br_y = r[1] + r[3] - 1

    if shiftType == 'scale_7':
        ratio = 0.7
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_8':
        ratio = 0.8
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_9':
        ratio = 0.9
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_11':
        ratio = 1.1
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_12':
        ratio = 1.2
        w = ratio * r[2] # 104.4
        h = ratio * r[3] # 382.8
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_13':
        ratio = 1.3
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'left':
        r[0] -= round(0.1 * r[2] + 0.5)

    elif shiftType == 'right':
        r[0] += round(0.1 * r[2] + 0.5)

    elif shiftType == 'up':
        r[1] -= round(0.1 * r[3] + 0.5)

    elif shiftType == 'down':
        r[2] += round(0.1 * r[3] + 0.5)

    elif shiftType == 'topLeft':
        r[0] = round(r[0] - 0.1 * r[2])
        r[1] = round(r[1] - 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    elif shiftType == 'topRight':
        br_x = round(br_x + 0.1 * r[2])
        r[1] = round(r[1] - 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    elif shiftType == 'bottomLeft':
        r[0] = round(r[0] - 0.1 * r[2])
        br_y = round(br_y + 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    elif shiftType == 'bottomRight':
        br_x = round(br_x + 0.1 * r[2])
        br_y = round(br_y + 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    if r[0] < 1:
        r[0] = 1

    if r[1] < 1:
        r[1] = 1

    if r[0] + r[2] - 1 > imgW:
        r[2] = imgW - r[0] + 1

    if r[1] + r[3] - 1 > imgH:
        r[3] = imgH - r[1] + 1

    return r

