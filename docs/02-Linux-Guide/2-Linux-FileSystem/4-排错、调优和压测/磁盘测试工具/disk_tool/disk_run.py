# -*- coding:utf-8 -*-
import yaml
import subprocess
import sys
import argparse
import re
import logging
def yaml_load():
    with open('disk.yml',"r+") as f:
        config_json = yaml.load(f)
    return config_json

def get_logger():

    logger = logging.getLogger(__name__)
    logger.setLevel(level=logging.INFO)
    handler = logging.FileHandler("log.txt")
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    logger.addHandler(handler)
    logger.addHandler(console)
    return logger
log = get_logger()

def result_analysis(_str,_type):
    _dict = {}
    result = _str.split("\n")
    for _text in result:
        if re.search("IOPS=", _text) and _type == "iops":
            _iops = _text.split(",")[0].split("=")[1]
            if re.search("k|K", _iops):
                _tmp = re.split("K|k", _iops)[0]
                _value = float(_tmp) * 1000
                _dict['iops'] =  _value
            else:
                #print _tmp
                _value = _iops
                _dict['iops'] = _value
        if re.search("IOPS=", _text) and _type == "bw":
            if re.search("\d+MB|\d+KB|\d+\.\d+MB|\d+\.\d+KB", _text):
                _value = re.search("\d+MB|\d+KB|\d+\.\d+MB|\d+\.\d+KB", _text).group()
                _dict['bw'] = _value
        if re.search("ios=", _text):
            _value = re.search("util=\d+.*%", _text).group().split("=")[1]
            _dict['util'] = _value
    #print _dict
    return _dict
def subprocess_fuc(_cmd):
    cmd = subprocess.Popen(_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stout, sterr) =cmd.communicate()
    if len(sterr) > 0 :
        print "{} execute failed,error_info:{}".format(_cmd,sterr)
        sys.exit()
    else:
        return stout

def args_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--filename',help="指定文件系统目录或者裸盘设备",default=None)
    parser.add_argument('--type',help="0表示测试文件系统,1表示测试裸盘设备",default=0)
    args = parser.parse_args()
    return args
def file_test_clean(file,tag):
    if tag == 0:
        cmd =  'rm -f {}'.format(file)
        stdout = subprocess_fuc(cmd)
        print stdout
if __name__ == '__main__':
    fio_result = {}
    _args = args_parser()
    config_json = yaml_load()
    print _args.type
    if _args.type == 0:
      filename = _args.filename + '/fiotest'
      #清理文件标志
      clean_tag = 0
    else:
        filename = _args.filename
    fio_result[_args.filename] = {}
    #测试顺序写吞吐
    cmd = 'fio -name=bw_Test1 -group_reporting -direct=1 -iodepth={} -rw=write -ioengine=libaio -refill_buffers -norandommap -randrepeat=0 -bs={} -size={} -numjobs={}  -runtime=5 -filename={}'.format(config_json['write_swallow_iodepth'],config_json['write_swallow_bs'],config_json['write_swallow_size'],config_json['write_swallow_numjobs'],filename)
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp = result_analysis(_result,'bw')
    fio_result[_args.filename]['write_swallow'] = tmp
    #file_test_clean(filename,clean_tag)
    #测试顺序读吞吐
    cmd = 'fio -name=bw_Test2 -group_reporting -direct=1 -iodepth={} -rw=read -ioengine=libaio -refill_buffers -norandommap -randrepeat=0 -bs={} -size={} -numjobs={} -runtime=300 -filename={}'.format(config_json['read_swallow_iodepth'],config_json['read_swallow_bs'],config_json['read_swallow_size'],config_json['read_swallow_numjobs'],filename)
    #print cmd
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp = result_analysis(_result,'bw')
    fio_result[_args.filename]['read_swallow'] = tmp
    if _args.type == 0:
       file_test_clean(filename, clean_tag)
    #测试随机写吞吐
    cmd = 'fio -name=bw_Test3 -group_reporting -direct=1 -iodepth={} -rw=randwrite -ioengine=libaio -refill_buffers -norandommap -randrepeat=0 -bs={} -size={} -numjobs={} -runtime=30 -filename={}'.format(config_json['randwrite_swallow_iodepth'],config_json['randwrite_swallow_bs'],config_json['randwrite_swallow_size'],config_json['randwrite_swallow_numjobs'],filename)
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp = result_analysis(_result, 'bw')
    fio_result[_args.filename]['randwrite_swallow'] = tmp
    #测试随机读吞吐
    cmd = 'fio -randrepeat=1 -ioengine=libaio -direct=1 -gtod_reduce=1 -name=bw_rwtest4 -filename={}  -bs={} -iodepth={} -size={} -readwrite=randread'.format(filename,config_json['randread_swallow_bs'],config_json['randread_swallow_iodepth'],config_json['randread_swallow_size'])
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp =result_analysis(_result,'bw')
    fio_result[_args.filename]['randread_swallow'] = tmp
    if _args.type == 0:
       file_test_clean(filename, clean_tag)
    #测试顺序写IOPS
    cmd = 'fio -name=IOPS_Test1 -group_reporting  -direct=1 -iodepth={} -rw=write -ioengine=libaio -refill_buffers -norandommap -randrepeat=0 -bs={} -size={} -numjobs={} -runtime=30 -filename={}'.format(config_json['write_iops_iodepth'],config_json['write_iops_bs'],config_json['write_iops_size'],config_json['write_iops_numjobs'],filename)
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp = result_analysis(_result, 'iops')
    fio_result[_args.filename]['write_iops'] = tmp
    #file_test_clean(filename, clean_tag)
    # 测试顺序读IOPS
    cmd = 'fio -name=IOPS_Test2 -group_reporting -direct=1 -iodepth={} -rw=read -ioengine=libaio -refill_buffers -norandommap -randrepeat=0 -bs={} -size={} -numjobs={} -runtime=30 -filename={}'.format(config_json['read_iops_iodepth'], config_json['read_iops_bs'], config_json['read_iops_size'],config_json['read_iops_numjobs'], filename)
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp = result_analysis(_result, 'iops')
    fio_result[_args.filename]['read_iops'] = tmp
    if _args.type == 0:
        file_test_clean(filename, clean_tag)
    #测试随机写IOPS
    cmd = 'fio -name=IOPS_Test3 -group_reporting -direct=1 -iodepth={} -rw=randwrite -ioengine=libaio -refill_buffers -norandommap -randrepeat=0 -bs={} -size={} -numjobs={} -runtime=30 -filename={}'.format(config_json['randwrite_iops_iodepth'],config_json['randwrite_iops_bs'],config_json['randwrite_iops_size'],config_json['randwrite_iops_numjobs'],filename)
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp = result_analysis(_result, 'iops')
    fio_result[_args.filename]['randwrite_iops'] = tmp
     #file_test_clean(filename, clean_tag)
    #测试随机读IOPS
    cmd = 'fio -name=IOPS_Test4 -group_reporting -direct=1 -iodepth={} -rw=randread -ioengine=libaio -refill_buffers -norandommap -randrepeat=0 -bs={} -size={} -numjobs={} -runtime=30 -filename={}'.format(config_json['randread_iops_iodepth'],config_json['randread_iops_bs'],config_json['randread_iops_size'],config_json['randread_iops_numjobs'],filename)
    _result = subprocess_fuc(cmd)
    print _result
    log.info(_result)
    tmp = result_analysis(_result, 'iops')
    fio_result[_args.filename]['randread_iops'] = tmp
    print fio_result
    if _args.type == 0:
        file_test_clean(filename, clean_tag)
    print "device:{} 磁盘性能指标:".format(_args.filename)
    print "顺序读吞吐带宽:{}/s".format(fio_result[_args.filename]['read_swallow']['bw'])
    print "顺序写吞吐带宽:{}/s".format(fio_result[_args.filename]['write_swallow']['bw'])
    print "随机读吞吐带宽:{}/s".format(fio_result[_args.filename]['randread_swallow']['bw'])
    print "随机写吞吐带宽:{}/s".format(fio_result[_args.filename]['randwrite_swallow']['bw'])
    print "顺序读iops:{}/s".format(fio_result[_args.filename]['read_iops']['iops'])
    print "顺序写iops:{}/s".format(fio_result[_args.filename]['write_iops']['iops'])
    print "随机读iops:{}/s".format(fio_result[_args.filename]['randread_iops']['iops'])
    print "随机写iops:{}/s".format(fio_result[_args.filename]['randwrite_iops']['iops'])