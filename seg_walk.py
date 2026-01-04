import cv2
import numpy as np

cap = cv2.VideoCapture(0)  # Webcam

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    # Simple target detect (red object)
    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, (0, 100, 100), (10, 255, 255))
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if contours:
        largest = max(contours, key=cv2.contourArea)
        (x, y), radius = cv2.minEnclosingCircle(largest)
        center = (int(x), int(y))
        
        # Vitality stub: "coherence" from contour stability
        vitality = min(radius / 100, 1.0)  # Bigger target = higher "coherence"
        print(f"Vitality: {vitality:.2f} — Aim Lock")
        
        cv2.circle(frame, center, int(radius), (0, 255, 0), 2)
        cv2.putText(frame, f"Target Locked | V={vitality:.2f}", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
    
    cv2.imshow("Sovereign Aim Bot", frame)
    
    if cv2.waitKey(1) == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()