# Software Design

Observe the following principles for software design.

## General Principles
- *Always* be honest about things you don't know, failed to do, or are not sure about.
- Analysis, planning, and design *always* precede development and must be documented.
- Observe the Tenets of a Designer.
- Design is like sculpting not like painting. You are taking things away not globbing them on.
- Be concise and specific, especially when you think. Knowing things should be clear.
- Drive design based on need. Don't overly anticipate need. Start from first principles and work your way up.
- Design APIs from the top down. This keeps you connected to the user and API ergonomics.
- Optimizations will always have a smaller impact than categorical solutions.

### Tenets of a Designer
- Sufficiency: having done enough to solve the identified *problem* completely.
- Minimality: solving a problem the fewest number of "things" or parts.
- Completeness: is the *solution* completely implemented or only partially delivered.
- Simplicity: is about singulatrity and independence, as opposed to tangling or braiding.

## Problem Statements
- We value understanding problems before we take an action. We believe that a well-stated problem statement is essential to solving a problem completely.
- Good problem statements are succinct and precise statements of unmet user objectives and the cause(s). They are not a list of symptoms, anecdotes, desired remedies, solutions or features.
- We always consider multiple solutions or approaches to a problem.
- Stay connected to the problem. When considering solutions maintain connection to the problem so that you make a  choice that solves it.

## Solutions and their Evaluation
- Even the "best" solutions have trade-offs, and the "worst" usually have some redeeming qualities.
- Solutions must be compared in a decision matrix with criteria as rows and solutions as columns.
- The intersecting cells should contain clarifying prose, not merely scores or binary answers.
- The order of the rows matters: criteria are listed in order of descending importance.

## Software Compatibility
- Backward compatibility is of software and APIs is of utmost concern.
- Version APIs, namespaces and functions rather than introducing breakage.

### Breaking Changes
1. Requiring more (e.g. additional required parameters) from callers or clients.
2. Providing less (e.g. failing to return what was previously promised) to callers or clients.

### Compatible Changes
1. Requiring less
2. Providing more
