# External module imp
import RPi.GPIO as GPIO

init = False

GPIO.setmode(GPIO.BOARD) # Broadcom pin-numbering scheme
GPIO.setwarnings(False)

def init_output(pin):
    GPIO.setup(pin, GPIO.OUT)
    GPIO.output(pin, GPIO.LOW)
    GPIO.output(pin, GPIO.HIGH)

def off(pump_pin = 7):
    init_output(pump_pin)
    GPIO.output(pump_pin, GPIO.HIGH)

off()
