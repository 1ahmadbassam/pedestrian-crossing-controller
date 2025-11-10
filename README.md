# Pedestrian Crossing Traffic Light Controller

This repository contains the Verilog code for an FSM-based pedestrian crossing traffic light controller, developed for EECE 320: Digital Systems Design as a course project.

## Project Overview

The controller manages a pedestrian crossing on a two-way (east-west) street. The system includes two traffic signals for vehicles and two pedestrian signals.

* **Inputs:**
    * `clk`: System clock
    * `reset`: Asynchronous reset
    * `NB`: North pedestrian button
    * `SB`: South pedestrian button
* **Outputs:**
    * `TG`, `TY`, `TR`: Traffic Green, Yellow, Red signals
    * `PG`, `PR`: Pedestrian Green, Red signals

## Functional Sequence

By default, the traffic light is green (TG) and pedestrian signals are red (PR). When a pedestrian presses either the `NB` or `SB` button, the controller initiates the following timed sequence:

1.  **Traffic Yellow (TY):** 2 clock cycles
2.  **Traffic Red (TR):** 2 clock cycles
3.  **Pedestrian Green (PG):** 6 clock cycles
4.  **Pedestrian Flashing Green (PG):** 6 clock cycles (PG is tied to `~clk`)
5.  **Pedestrian Red (PR):** 2 clock cycles (grace period)
6.  **Traffic Green (TG):** The system returns to the default state.

A key requirement is that after a pedestrian cycle, the traffic light must remain green for a minimum of **12 clock cycles** to allow traffic to flow before any new button presses are registered.

## Implementation Details

The controller is designed as a Finite State Machine (FSM) using behavioral Verilog. A 4-bit synchronous counter is instantiated within the controller to manage the cycle timings for each state. The FSM transitions to the next state based on the counter's value.

There are seven states (A-G) corresponding to the functional sequence described above.

## File Descriptions

This repository includes two main versions of the controller:

### `controller_no_recall.sv`

This file contains the initial implementation of the controller and its testbench (`controller_tb`).

* In this version, if a pedestrian presses a button *while* a crossing sequence is already in progress, the press is ignored.
* The controller will only respond to a new press after it has fully completed the sequence and returned to the idle state (State A).

### `controller_final.sv`

This is the final, improved version of the controller, which includes a "recall" feature.

* **Recall Feature:** This controller uses an extra register (`open_traf`) to "remember" if `NB` or `SB` was pressed *during* an active cycle.
* If a press is "recalled," the FSM will automatically start a new pedestrian sequence immediately after the mandatory 12-cycle "Traffic Green" (State G) period, skipping the idle State A.
* This file contains `controller_tb2()`, a testbench specifically designed to test and verify this recall functionality.

## Waveform Screenshots

The included `.png` images are screenshots from EPWave. They show the simulation results of the testbenches, verifying the correct state transitions, timings, and output signals for various scenarios, including sequential button presses and the "recall" feature.
