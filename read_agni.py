import glob
import re
import json

with open('config.json') as json_file:
    config_data = json.load(json_file)
agni_directory_path = config_data['agni_path'] + '/'

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
        keyword_splited_arr = re.split(r'\s{4,}', keyword_content)
        if len(keyword_splited_arr) == 1:
            keyword_name = keyword_splited_arr[0].strip()
        else:
            str = re.sub(r"\$|\'|\"", "", keyword_content)
            for item in re.split(r'\s{3,}', str):
                if not '{' in item and not '=' in item:
                    keyword_name = item.strip()
                    # print keyword_name
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

with open('agni_keywords.json', 'w') as outfile:
    json.dump(data, outfile)
print data
