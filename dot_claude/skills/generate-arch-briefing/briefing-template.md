# <Software-Name> Architecture

## Description
A categorical description of the software, for example: "Clockwise is a date and time calculation library, offering a consistent interface over JVM time values, prioritizing the UTC timeline, with a bias for type agnosticism where it is practical."

## What Problems Does this Solve?
This is the most important part of the document. We build software to solve problems. Good software is clearly pointed at solving one problem (or a very few) well. When summarizing software that you did not build, try to put
yourself in the shoes of those who did. What was their mission? What problems were they taking on? How did they intend to distinguish their solution from others? Try to avoid this being a list of features without connecting those features to problems.

## Fundamental Semantics

### Primary Operations
These are the verbs of the system. What are the most important operations or APIs of this software?

### Is it Simple?
Simple things maintain focus on a concept or activity rather than interleaving concerns. Complex things mix, entangle, or braid together multiple concerns. Simple things can be combined with other simple things to make more complex things. Don't just answer this with a binary "yes" or "no."

## Architectural Overview

### Key Components
Are there multiple components, processes or services involved? How do they fit together? List any key storage, database, or message queuing systems. A system data flow diagram should be included here.

## Fundamental Trade-Offs
These are trade-offs in the design itself. We need to be explicit about these trade-offs in order to make good decisions and to prepare compensations. Trade-offs should be expressed in terms of "gives up X to get Y", and not just a list of negatives.

## Contra/Indicators for Use
Under what circumstances is this software a good fit for a problem and why? Conversly, under what circumstances is it a poor fit and why?

## Alternatives
Are there alternative solutions in same the space? In what ways do they differ? Do they take on a slightly different problem set, emphasize different aspects, or make different trade-offs?

## Application Characteristics
Describe any environment requirements and dependencies. Links to additional documentation should be included here.

## Operational Characteristics
Are there operational (throughput, latency, scalability, security) aspects which should be highlighted?

## Usage
List any critical decisions the user of this software must make when applying this technology to a problem. Highlight the consequences or trade-offs of each choice.

## Costs
If there are any known licensing or operational costs, they should be included here. If there are none, or this is unknown, omit this section.

## Additional Resources
Include links to any related content, presentations, or prior art so readers can learn more as a bulleted list.
