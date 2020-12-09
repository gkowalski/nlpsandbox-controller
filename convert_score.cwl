#!/usr/bin/env cwl-runner
#
# Convert annotated notes to annotation store annotations
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

hints:
  DockerRequirement:
    dockerPull: python:3.7

inputs:

  - id: score_json
    type: File

arguments:
  - valueFrom: convert_score.py
  - valueFrom: $(inputs.score_json)
    prefix: -s
  - valueFrom: results.json
    prefix: -r


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: convert_score.py
        entry: |
          #!/usr/bin/env python
          import argparse
          import json

          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--score_json", required=True, help="Score json file")
          parser.add_argument("-r", "--results", required=True, help="Results file")
          args = parser.parse_args()
        
          with open(args.score_json, "r") as score_f:
              scores = json.load(score_f)
          
          annotator_type = "date"
          key = f"{annotator_type}_location"
          new_scores_dict = {"location_{metric}_{type}_{mode}".format(
                                 metric=location['metric'],
                                 type=location['type'], mode=location['mode']
                             ): location['value']
                             for location in scores[key]}
          
          # key = f"{annotator_type}_type"
          # for types in scores[key]:
          #     new_scores_dict[f"type_{types['metric']}"] = types['value']
          new_scores_dict['submission_status'] = 'SCORED'

          with open(args.results, "w") as results_f:
              json.dump(new_scores_dict, results_f)

     
outputs:

  - id: results
    type: File
    outputBinding:
      glob: results.json   