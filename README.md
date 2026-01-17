# Digital Watch Design and Verification Project

This repository contains the complete RTL design and UVM-based verification environment for a Digital Watch system supporting:
- Normal timekeeping
- Time setting
- Alarm setting
- Stopwatch (elapsed and split modes)

## Repository Structure

- Architecture/  
  High-level system architecture and block diagrams.

- Design/  
  SystemVerilog RTL source files for the Digital Watch design.

- UVM/  
  Complete UVM verification environment including random and directed sequences.

- Simulation/  
  Simulation scripts and waveform configurations.

- Vivado Documentation/  
  Synthesis, elaboration, and implementation snapshots generated using Vivado.  
  All reports show no critical warnings or errors.

- [Documentation](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Documentation/Project_1_ASIC.pdf)/  
  Project documentation and report resources.

## Verification Methodology

The verification environment combines constrained-random stimulus and multiple directed sequences to achieve full functional coverage.  
Over 50,000 successful transactions were executed, resulting in 100% functional coverage.

## Tools Used
- QuestaSim (UVM)
- Vivado
- SystemVerilog / UVM

---

## Design Architecture
The Digital Watch design follows a modular and hierarchical architecture that integrates three main components:

- Normal Clock for real-time tracking and alarm functionality
- Stopwatch supporting elapsed and split-time mode
- Digital Watch FSM acting as the central control unit

![design](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Architecture/Digital_Watch_Diagram.png)

---

## Design FSM
The Digital Watch FSM controls the system operation through four main states:

- Normal: Displays the current time and monitors the alarm
- Set Time: Allows the user to configure the current time digit by digit
- Set Alarm: Allows the user to configure the alarm time
- Stopwatch: Controls stopwatch operation including elapsed and split modes

![fsm](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Architecture/fsm2.drawio.png)

---

## UVM Architecture
The simulation transcript confirms the successful execution of all test phases, including reset, random testing, and directed sequences.

![UVM_Arch](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Architecture/UVM_Architecture.png)

---

## UVM Transcript
The simulation transcript summarizes the overall verification results and confirms that all test phases executed successfully without any runtime issues.
![trans](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Documentation/UVM_Transcript.png)

---

## Vivado Elaboration
Vivado elaboration was performed successfully, confirming correct module hierarchy, signal connectivity, and design integrity.

![ela](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Vivado%20Documentation/Elaboration.png)

---

## Vivado Synthesis
The synthesis process completed without any critical warnings or errors.

![Syn](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Vivado%20Documentation/Senthesis.png)

---

## Vivado Messages

![mess](https://github.com/MohamedHussein27/Digital_Watch_Design_and_UVM_Verification/blob/main/Vivado%20Documentation/Messages.png)

---

## Contact Me!
- [Email](mailto:Mohamed_Hussein2100924@outlook.com)
- [WhatsApp](https://wa.me/+2001097685797)
- [LinkedIn](https://www.linkedin.com/in/mohamed-hussein-274337231)
