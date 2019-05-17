#!/usr/bin/env python3
# modifier: phien.ngo
import os
import re
from argparse import ArgumentParser


def detectCommentLine(yaml_content, format_structure):
  regex = r"(#.*)\n([\s]{0,})(.*)\n"
  matches = re.finditer(regex, yaml_content, re.MULTILINE)
  for matchNum, match in enumerate(matches, start=1):
    if len(match.groups()) >= 2:
      comment_line = match.group(1)
      space_of_next_line = match.end(2) - match.start(2)
      next_line = match.group(3)
      if next_line in format_structure:
        format_structure[comment_line.strip()] = {'line': None, 'indent': format_structure[next_line]['indent']}
      else:
        format_structure[comment_line.strip()] = {'line': None, 'indent': space_of_next_line}

  return format_structure


def detectChecksOption(yaml_content, format_structure):
  checks_options = re.findall('(- .*)\n', yaml_content)
  for item in checks_options:
    format_structure[item.strip()] = {'line': None, 'indent': 39}
  return format_structure


def detect_common_variables(yaml_content, format_structure):
  found = False
  i = 0
  for line in yaml_content.split('\n'):
    i = i + 1
    if "common_variables" in line:
      found = True
      continue
    if found and "steps" not in line:
      format_structure[line.strip()] = {'line': i, 'indent': 17}
    if "steps" in line:
      found = False
      continue

  return format_structure


def detect_file(yaml_content, format_structure):
  # detect testcase name
  testcase_name_list = re.findall('[\s]{0,}(.*)\n.*common_variables:', yaml_content)
  for item in testcase_name_list:
    format_structure[item.strip()] = {'line': None, 'indent': 4}
  # detect all common variables
  format_structure = detect_common_variables(yaml_content, format_structure)
  # detect index step
  index_step_list = re.findall('\n[\s]{0,}(\d+:)\n', yaml_content)
  for item in index_step_list:
    format_structure[item.strip()] = {'line': None, 'indent': 17}
  # detect stepname
  index_stepname_list = re.findall('\n[\s]{0,}\d+:[\s]{0,}(.*)\n', yaml_content)
  for item in index_stepname_list:
    format_structure[item.strip()] = {'line': None, 'indent': 21}
  # detect sub step has operator
  index_substep_operator_list = re.findall('(.*_operator:.*\n)', yaml_content)
  for item in index_substep_operator_list:
    format_structure[item.strip()] = {'line': None, 'indent': 29}
  # detect sub step has value
  index_substep_value_list = re.findall('(.*_value:.*\n)', yaml_content)
  for item in index_substep_value_list:
    format_structure[item.strip()] = {'line': None, 'indent': 29}
  # detect checks options
  format_structure = detectChecksOption(yaml_content, format_structure)
  # detect comment line
  format_structure = detectCommentLine(yaml_content, format_structure)
  return format_structure


def update_unique_ids_and_format(yaml_file=None, uid=1):
  format_structure = {
    "Granular_tests:": {'line': None, 'indent': 0},
    "common_variables:": {'line': None, 'indent': 8},
    "steps:": {'line': None, 'indent': 8},
    "create_dictionary_and_check:": {'line': None, 'indent': 25},
    "unique_id:": {'line': None, 'indent': 25},
    "create_dictionary_and_get:": {'line': None, 'indent': 25},
    "run_event:": {'line': None, 'indent': 25},
    "clear_traffic_stats:": {'line': None, 'indent': 25},
    "check_traffic_and_get_convergence:": {'line': None, 'indent': 25},
    "clear_and_check_traffic_stats:": {'line': None, 'indent': 25},
    "confirm_traffic_drops:": {'line': None, 'indent': 25},
    "run_keyword:": {'line': None, 'indent': 25},
    "devices: device": {'line': None, 'indent': 29},
    "keyword:": {'line': None, 'indent': 29},
    "checks:": {'line': None, 'indent': 29},
    "positional_args_list:": {'line': None, 'indent': 29},
    "return_variable_name:": {'line': None, 'indent': 29},
    "return_status:": {'line': None, 'indent': 29},
    "loop_over_list:": {'line': None, 'indent': 29}
  }
  unique_ids_mapping = {
    'routing_interfaces.yaml': 1,
    'routing_mpls.yaml': 5000,
    'routing_platform.yaml': 10000,
    'routing_protocols.yaml': 15000,
    'dc_ethernet_switching.yaml': 20000,
    'dc_interfaces.yaml': 25000,
    'dc_management.yaml': 30000,
    'dc_protocols.yaml': 35000,
    'dc_security.yaml': 40000,
    'dc_virtualchassis.yaml': 45000,
    'platform_fusion.yaml': 50000,
    'security_interface.yaml': 55000,
    'platform.yaml': 60000,
    'security_platform.yaml': 65000,
    'security_ipsec.yaml': 70000,
    'security_firewall.yaml': 75000
  }
  yaml_file_name = os.path.split(yaml_file)[-1]

  if yaml_file_name in unique_ids_mapping.keys():
    uid = unique_ids_mapping[yaml_file_name]
  with open(yaml_file, 'r') as fr:
    yaml_content = fr.read()
  format_structure = detect_file(yaml_content, format_structure);
  counter = int(uid)
  steps_counter = 1
  fw = open(yaml_file, 'w')
  i = 0
  contentToWrite = ''
  for line in yaml_content.split('\n'):
    i = i + 1
    if 'steps:' in line:
      steps_counter = 1
    if 'unique_id:' in line:
      line = line.split(':')[0] + ': ' + str(counter)
      counter += 1
      format_structure[line.strip()] = {'line': None, 'indent': 25}
    if re.search('^\s*\d+\:$', line):
      spaces = 17
      line = ' ' * spaces + str(steps_counter) + ':'
      steps_counter += 1

    # format indent for the line
    line_content = line.strip();
    if line_content in format_structure.keys():
      if format_structure[line_content]['line'] is None:
        line = ' ' * format_structure[line_content]['indent'] + line_content
      else:
        if format_structure[line_content]['line'] == i:
          line = ' ' * format_structure[line_content]['indent'] + line_content
    contentToWrite = contentToWrite + line + '\n'
  fw.write(contentToWrite.strip())
  fw.close()


def generateStep(arrStepObjs, file_name, testcase_name, username):
  stepsToWrite = getHeaderContent(testcase_name, username)
  for stepObj in arrStepObjs:
    if stepObj != '':
      stepsToWrite = getStepContent({'keyword': stepObj.split('#')[0], 'step_name': stepObj.split('#')[1]},
                                    stepsToWrite)
  pth_of_file = 'output/test_case_generate.yaml'
  if file_name is not None:
    pth_of_file = 'output/' + file_name
  fw = open(pth_of_file, 'w')
  fw.write(stepsToWrite.strip())
  fw.close()
  update_unique_ids_and_format(pth_of_file)


def getHeaderContent(testcase_name, username):
  result = ''
  yaml_file = 'tcs.yaml'
  with open(yaml_file, 'r') as fr:
    yaml_content = fr.read()

  write_code_before_step = True
  for line in yaml_content.split('\n'):
    if line.strip() == 'steps:':
      write_code_before_step = False
      result = result + line + '\n'
    if write_code_before_step == True:
      if testcase_name is not None:
        line = line.replace('testcase_name', testcase_name)
      if username is not None:
        line = line.replace('owner_name', username)
      result = result + line + '\n'
  return result


def getStepContent(stepObj, result):
  yaml_file = 'tcs.yaml'
  with open(yaml_file, 'r') as fr:
    yaml_content = fr.read()

  found = False
  for line in yaml_content.split('\n'):
    # detect step to write
    if re.sub(r"#|@", "", line).strip() == stepObj['keyword']:
      found = True
      continue
    if found and '#####' not in line:
      line = line.replace('step_name', stepObj['step_name'])
      result = result + line + '\n'
    if "#####" in line:
      found = False
      continue
  return result


def main():
  argparser = ArgumentParser('python main.py -yaml=<yaml_file>')
  argparser.add_argument('-f', '--yaml_file', default=None, help='yaml file to update and format indent')
  argparser.add_argument('-u', '--unique_id', default=1, help='unique id to start for file')
  argparser.add_argument('-s', '--listStep', nargs='+', default=None, help='String of Step in format step#keyword step1#keyword1')
  argparser.add_argument('-tn', '--testcase_name', default=None, help='Name of testcase')
  argparser.add_argument('-fn', '--file_name', default=None, help='File name of testcase')
  argparser.add_argument('-usr', '--username', default=None, help='User name')
  args = argparser.parse_args()
  yaml_file = args.yaml_file
  start_unique_id = args.unique_id
  listStep = args.listStep
  testcase_name = args.testcase_name
  file_name = args.file_name
  username = args.username
  if not os.path.isdir('output'):
    os.mkdir('output')
  if yaml_file is not None and start_unique_id is not None:
    update_unique_ids_and_format(yaml_file=yaml_file, uid=start_unique_id)
  if listStep is not None:
    generateStep(listStep, file_name, testcase_name, username)


if __name__ == '__main__':
  main()
