"""
@Time ： 7/13/2021 14:34 PM
@File ：create_oss_downloadurl.py
@IDE ：PyCharm
__author__ = 'hozin'
"""
# -*- coding: utf-8 -*-
#环境依赖 && 官方文档
#pip install -U cos-python-sdk-v5
#https://cloud.tencent.com/document/product/436/12269
#生成exe 小工具
#pip install pyinstaller
#pyinstaller.exe -F --icon=logo.ico ..\..\create_oss_downloadurl.py
import logging,sys
from qcloud_cos import CosConfig
from qcloud_cos import CosS3Client
logging.basicConfig(level=logging.INFO, stream=sys.stdout)
secret_id = ''      # 替换为用户的 secretId(登录访问管理控制台获取)
secret_key = ''      # 替换为用户的 secretKey(登录访问管理控制台获取)
region = 'ap-tokyo'     # 替换为用户的 Region
token = None                # 使用临时密钥需要传入 Token，默认为空，可不填
scheme = 'https'            # 指定使用 http/https 协议来访问 COS，默认为 https，可不填
config = CosConfig(Region=region, SecretId=secret_id, SecretKey=secret_key, Token=token, Scheme=scheme)
# 2. 获取客户端对象
client = CosS3Client(config)

import os
dir="c:\\share\oss_rsync"
base_uri='https://jp-1301785062.cos.ap-tokyo.myqcloud.com'
bucket='jp-1301785062'

def get_file_download_url(bucket,file_name_path):
    response = client.get_object_url(
        Bucket=bucket,
        Key=file_name_path
    )
    return response
list_url=[]
for parent, dirnames, filenames in os.walk(dir):
    for filename in filenames:
        file_path = os.path.join(parent, filename)
        print(file_path)
        list_url.append(file_path.replace(dir+'\\','').replace('\\','/'))
with open('download_urls.log', mode='w' ,encoding="utf8") as f4:
    for i in list_url:
        f4.writelines(("文件:%s 下载地址为"%(i))+"\n")
        f4.writelines(get_file_download_url(bucket,i) + '\n')
