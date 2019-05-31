from os import listdir
from os.path import isfile, join
import glob
mypath = 'D:\\PhienNT\\Juniper\\Juniper_Source\\agni\\'

arrYamlFiles = glob.glob(mypath+"*.yaml")
print(glob.glob(mypath+"*.yaml"))
for yaml_file in arrYamlFiles:
  print(yaml_file)
  with open(yaml_file, 'r') as fr:
    yaml_content = fr.read()
    print yaml_content
