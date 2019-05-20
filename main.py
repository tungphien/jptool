#!/usr/bin/env python3
# modifier: phien.ngo
import os
import re
from argparse import ArgumentParser
import json
import glob

AGNI_KEYWORD_TEMP_FILES = 'agni_keywords.json'
TESTCASE_TEMPLATE_FILE = 'tcs.yaml'
CONFIG_FILE = 'config.json'

def detectCommentLine(yaml_content, format_structure):
  regex = r"(#.*)\n([\s]{0,})(.*)\n"
  matches = re.finditer(regex, yaml_content, re.MULTILINE)
  for matchNum, match in enumerate(matches, start=1):
    if len(match.groups()) >= 2:
      comment_line = match.group(1)
      space_of_next_line = match.end(2) - match.start(2)
      next_line = match.group(3)
      if next_line + '@None' in format_structure:
        format_structure[comment_line.strip() + '@None'] = format_structure[next_line + '@None']
      else:
        format_structure[comment_line.strip() + '@None'] = space_of_next_line

  return format_structure


def detectChecksOption(yaml_content, format_structure):
  checks_options = re.findall('(- .*)\n', yaml_content)
  for item in checks_options:
    format_structure[item.strip() + '@None'] = 39
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
      format_structure[line.strip() + '@' + str(i)] = 17
    if "steps" in line:
      found = False
      continue

  return format_structure


def detect_subcommon_function(yaml_content, format_structure):
  found = False
  i = 0
  for line in yaml_content.split('\n'):
    i = i + 1
    if 'run_keyword:' in line or 'run_event:' in line \
            or 'create_dictionary_and_get' in line or 'create_dictionary_and_check' in line:
      found = True
      continue
    if found and "unique_id" not in line:
      format_structure[line.strip() + '@' + str(i)] = 29
    if "unique_id" in line:
      found = False
      continue

  return format_structure


def detect_file(yaml_content, format_structure):
  # detect testcase name
  testcase_name_list = re.findall('[\s]{0,}(.*)\n.*common_variables:', yaml_content)
  for item in testcase_name_list:
    format_structure[item.strip() + '@None'] = 4
  # detect all common variables
  format_structure = detect_common_variables(yaml_content, format_structure)
  # detect index step
  index_step_list = re.findall('\n[\s]{0,}(\d+:)\n', yaml_content)
  for item in index_step_list:
    format_structure[item.strip() + '@None'] = 17
  # detect stepname
  index_stepname_list = re.findall('\n[\s]{0,}\d+:[\s]{0,}(.*)\n', yaml_content)
  for item in index_stepname_list:
    format_structure[item.strip() + '@None'] = 21
  # detect sub step has operator
  index_substep_operator_list = re.findall('(.*_operator:.*\n)', yaml_content)
  for item in index_substep_operator_list:
    format_structure[item.strip() + '@None'] = 29
  # detect sub step has value
  index_substep_value_list = re.findall('(.*_value:.*\n)', yaml_content)
  for item in index_substep_value_list:
    format_structure[item.strip() + '@None'] = 29
  # detect checks options
  format_structure = detectChecksOption(yaml_content, format_structure)
  # detect comment line
  format_structure = detectCommentLine(yaml_content, format_structure)
  # detect sub command of run_event, run_keyword, create_dictionary_and_get,..
  format_structure = detect_subcommon_function(yaml_content, format_structure)
  return format_structure


def update_unique_ids_and_format(yaml_file=None, uid=1):
  format_structure = {
    "Granular_tests:@None": 0,
    "common_variables:@None": 8,
    "steps:@None": 8,
    "devices: device@None": 29,
    "checks:@None": 29,
    "loop_over_list:@None": 29
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
    if 'run_keyword:' in line or 'run_event:' in line \
            or 'create_dictionary_and_get' in line or 'create_dictionary_and_check' in line:
      format_structure[line.strip() + '@' + str(i)] = 25
    if 'unique_id:' in line:
      line = line.split(':')[0] + ': ' + str(counter)
      counter += 1
      format_structure[line.strip() + '@' + str(i)] = 25
    if re.search('^\s*\d+\:$', line):
      spaces = 17
      line = ' ' * spaces + str(steps_counter) + ':'
      steps_counter += 1

    # format indent for the line
    line_content = line.strip();
    if line_content + '@None' in format_structure.keys():
      line = ' ' * format_structure[line_content + '@None'] + line_content
    else:
      if line_content + '@' + str(i) in format_structure.keys():
        line = ' ' * format_structure[line_content + '@' + str(i)] + line_content
    contentToWrite = contentToWrite + line + '\n'
  fw.write(contentToWrite.strip())
  fw.close()


def generateStep(arrStepObjs, file_name, testcase_name, username):
  stepsToWrite = getHeaderContent(testcase_name, username)
  for stepObj in arrStepObjs:
    if stepObj != '':
      arrItem = stepObj.split('#')
      data = {'function_step': arrItem[0], 'step_name': arrItem[1]}
      if len(arrItem) >= 3:
        data['keyword'] = arrItem[2]
      stepsToWrite = getStepContent(data, stepsToWrite)
  pth_of_file = 'output/test_case_generate.yaml'
  if file_name is not None:
    pth_of_file = 'output/' + file_name
  fw = open(pth_of_file, 'w')
  fw.write(stepsToWrite.strip())
  fw.close()
  update_unique_ids_and_format(pth_of_file)


def getHeaderContent(testcase_name, username):
  result = ''
  with open(TESTCASE_TEMPLATE_FILE, 'r') as fr:
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
  agni_keyword_data = {}
  with open(AGNI_KEYWORD_TEMP_FILES) as json_file:
    agni_keyword_data = json.load(json_file)['content']

  with open(TESTCASE_TEMPLATE_FILE, 'r') as fr:
    yaml_content = fr.read()

  found = False
  for line in yaml_content.split('\n'):
    # detect step to write
    if re.sub(r"#|@", "", line).strip() == stepObj['function_step']:
      found = True
      continue
    if found and '#####' not in line:
      line = line.replace('step_name', stepObj['step_name'])
      if 'keyword' in stepObj.keys():
        if stepObj['keyword'] in agni_keyword_data.keys():
          line = line.replace('<<keyword>>', agni_keyword_data[stepObj['keyword']])
        else:
          line = line.replace('<<keyword>>', stepObj['keyword'])
      result = result + line + '\n'
    if "#####" in line:
      found = False
      continue
  return result


def readAgniKeyword():
  with open(CONFIG_FILE) as json_file:
    config_data = json.load(json_file)

  agni_directory_path = config_data['agni_path'] + '\\'
  list_file_paths = glob.glob(agni_directory_path + "*.yaml")

  yaml_contents = ''
  for file_path in list_file_paths:
    with open(file_path, 'r') as fr:
      yaml_content = fr.read()
      yaml_contents = yaml_contents + '\n' + yaml_content
  # print(yaml_contents)

  list_keywords = re.findall('keyword:(.*)\n', yaml_contents)
  keywords_without_run_event = {}
  for keyword in list_keywords:

    if not keyword.strip().lower() == 'on config' and not keyword.strip().lower() == 'on cli':
      keyword_name = ''
      keyword = keyword.strip()
      keyword_content = re.sub(r"\'", "", keyword)
      keyword_splited_arr = re.split(r'\s{2,}', keyword_content)
      if len(keyword_splited_arr) == 1:
        keyword_name = keyword_splited_arr[0].strip().lower()
      else:
        str = re.sub(r"\$|\'|\"", "", keyword_content)
        for item in re.split(r'\s{2,}', str):
          if not '{' in item and not '=' in item:
            keyword_name = item.strip().lower()
            break
      if not keyword_name == '':
        if not keywords_without_run_event:
          if keyword_name not in keywords_without_run_event.keys():
            keywords_without_run_event[keyword_name] = keyword_content
        else:
          keywords_without_run_event[keyword_name] = keyword_content
  data = {
    'keywords': keywords_without_run_event.keys(),
    'content': keywords_without_run_event
  }

  with open(AGNI_KEYWORD_TEMP_FILES, 'w') as outfile:
    json.dump(data, outfile)
  print data


def main():
  argparser = ArgumentParser('python main.py -yaml=<yaml_file>')
  argparser.add_argument('-f', '--yaml_file', default=None, help='yaml file to update and format indent')
  argparser.add_argument('-u', '--unique_id', default=1, help='unique id to start for file')
  argparser.add_argument('-s', '--listStep', nargs='+', default=None,
                         help='String of Step in format step#keyword step1#keyword1')
  argparser.add_argument('-tn', '--testcase_name', default=None, help='Name of testcase')
  argparser.add_argument('-fn', '--file_name', default=None, help='File name of testcase')
  argparser.add_argument('-usr', '--username', default=None, help='User name')
  argparser.add_argument('-r', '--ragni', default=None, help='any value to read agni keyword from directory')
  args = argparser.parse_args()
  yaml_file = args.yaml_file
  start_unique_id = args.unique_id
  listStep = args.listStep
  testcase_name = args.testcase_name
  file_name = args.file_name
  username = args.username
  ragni = args.ragni
  if not os.path.isdir('output'):
    os.mkdir('output')
  if yaml_file is not None and start_unique_id is not None:
    update_unique_ids_and_format(yaml_file=yaml_file, uid=start_unique_id)
  if listStep is not None:
    generateStep(listStep, file_name, testcase_name, username)
  if ragni is not None:
    readAgniKeyword()

if __name__ == '__main__':
  main()
