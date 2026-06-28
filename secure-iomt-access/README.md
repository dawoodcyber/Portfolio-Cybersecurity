Secure IoMT Access Control & Intrusion Alert System

An embedded access-control system built on the AT89C52 (8051 architecture) microcontroller, exploring physical-layer security concepts relevant to IoMT (Internet of Medical Things) device protection. Unauthorized physical access to connected medical devices is a real and underappreciated attack vector in healthcare cybersecurity — this project models a basic PIN-based access control with brute-force lockout, implemented entirely in hand-written 8051 assembly on bare-metal hardware.

Overview

A user enters a 4-digit PIN via a 4x4 matrix keypad. The system validates the input in real time:


Correct PIN → Access granted, green LED activates, LCD confirms, system resets after a timeout.
Incorrect PIN → Red LED activates, LCD shows a warning, attempt counter increments.
3 consecutive failed attempts → System enters a lockout state: red LED + buzzer alarm activate, LCD displays "Access Blocked," and the system holds in lockout for a fixed duration before resetting — a fail-closed design pattern used in real-world access-control hardware to slow down brute-force attempts.


The full system was simulated and validated in Proteus before being built and debugged on physical hardware.

Hardware

ComponentPurposeAT89C52 microcontrollerCore processor running the authentication logic11.0592 MHz crystal oscillatorSystem clock (chosen for accurate UART/timing division)16x2 character LCDUser-facing status display4x4 matrix keypadPIN entry inputGreen / Red LEDsAccess granted / denied indicatorsBuzzerAudible intrusion alarm on lockoutReset circuit (RC network)Clean power-on reset

Software

Written entirely in 8051 Assembly (Keil A51 syntax). Core logic includes:


Keypad matrix scanning — row/column scan to detect and debounce key presses
Password buffer handling — stores 4-digit input for comparison
Attempt counter & lockout state machine — tracks failed attempts, triggers timed lockout
LCD driver routines — command/data writes, custom print routine for string buffers
Software delay routines — calibrated for the 11.0592 MHz clock for accurate timing of lockout/cooldown periods


See secure_access.asm for the full source.

Design notes & tradeoffs


Single-factor PIN authentication is inherently limited — this project demonstrates the mechanism of access control and lockout, not a production-grade auth scheme. A real IoMT deployment would pair this with additional factors (RFID, biometric, or network-level authentication).
Fail-closed lockout: after 3 failed attempts, the system actively denies further input for a fixed cooldown rather than allowing unlimited retries — a basic but important brute-force mitigation.
Sim-to-hardware gap: the logic worked correctly in Proteus simulation on the first pass, but physical hardware surfaced real issues not visible in simulation — most notably power-on race conditions (LCD initializing before stable voltage was reached) and signal integrity issues on the LCD data bus. These were resolved through reset circuit tuning (additional decoupling capacitance) and careful re-verification of every data line — a reminder that simulation validates logic, not physical reliability.


Repository contents


secure_access.asm — full 8051 assembly source
circuit_schematic.png — Proteus circuit diagram
README.md — this file


Tools used

8051 Assembly · Keil uVision (A51 assembler) · Proteus (circuit simulation & validation) · AT89C52 microcontroller
