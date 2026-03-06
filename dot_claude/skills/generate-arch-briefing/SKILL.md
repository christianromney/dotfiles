---
name: generate:arch-briefing
description: Generate an architectural briefing of the specified software
user_invocable: true
arguments:
    - name: software
      description: The name of the software to describe with an architectural briefing
      required: true
    - name: location
      description: The file path or URL where the software may be found
      required: true
    - name: output
      description: The file location where the briefing should be saved. Defaults to `$ARGUMENTS.software`-briefing.md
      required: false
---
# Generate Arch Briefing

Create an architectural briefing document for `$ARGUMENTS.software` strictly
following the format of the [briefing template](briefing-template.md).

## Steps
1. Read the [briefing template](briefing-template.md) to understand the analysis you must perform and the structure of the document you must create.
2. Analyze the software at `$ARGUMENTS.location`, reading source code and documentation as required
3. Create a plan for the document in outline form with specific references from the software's design
4. Output the requested architectural briefing in Markdown format.
  a. Replace the placeholder <Software-Name> in the template with the value of `$ARGUMENTS.software`
  b. Follow the heading structure of the [briefing template](briefing-template.md) but replace the content with your research findings.
  c. Generate a diagram of the primary operation(s) and display it in the document
  d. Include reference links and citations to authoritative sources
 
