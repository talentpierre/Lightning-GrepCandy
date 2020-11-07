# External module imp
import RPi.GPIO as GPIO

init = False

GPIO.setmode(GPIO.BOARD) # Broadcom pin-numbering scheme
GPIO.setwarnings(False)

def init_output(pin):
    GPIO.setup(pin, GPIO.OUT)
    GPIO.output(pin, GPIO.LOW)
    GPIO.output(pin, GPIO.HIGH)

def on(power_supply_pin = 11):
    init_output(power_supply_pin)
    GPIO.output(power_supply_pin, GPIO.HIGH)

on()
