## What These Simulations Actually Show and Don't

The three scripts in this repo (blackhole, grayhole, wormhole) are simplified,  visual simulations built around the RREQ flooding behavior of the AODV  protocol. The goal is to make the *idea* behind each attack visible and intuitive not to provide a protocol-accurate network simulation. For that, you'd want a proper tool like ns-3 or OMNeT++.
### What's actually modeled?
- Nodes move randomly at each step.
- An RREQ broadcast from the source node spreads outward hop by hop to neighbors within transmission range (`txRange`) a simplified breadth-first 
  search standing in for real RREQ flooding.
- Once the malicious nodes fall within that spreading RREQ, the attack is considered triggered, and the visuals and stats update accordingly.

### What's deliberately left out and why?
- **No RREP or route-selection mechanics.** In a real blackhole or grayhole attack, the malicious node lies during the RREP phase, advertising a fake, unusually high destination sequence number or a suspiciously low hop count  to trick the source into picking it as the "best" route. These scripts skip that step entirely: the attack is triggered the moment the malicious node enters the RREQ's reach. That shows the *precondition* for the attack, not the actual deception that 
  makes AODV choose it.
- **No data-plane traffic.** "Dropping a packet" here just represents the 
  outcome of a single RREQ round — there's no simulation of an actual data 
  flow with sequencing, retransmission, or multiple packets in flight.
- **The wormhole tunnel isn't modeled as a physical channel** — it's 
  represented purely as a shortcut in the graph topology.
- **Grayhole selectivity is approximated with a flat probability** 
  (`dropProbability`), rather than being based on packet type or timing, 
  as it often is in the literature.

### Why it's kept this simple
The point of this codebase is to make the *logic* of these three AODV attacks easy to see and follow, not to deliver a protocol-accurate performance 
evaluation. A study like that needs its own ns-3 or OMNeT++ based simulation; this repo is meant as the conceptual step before that, not a replacement for it.
