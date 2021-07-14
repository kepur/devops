import time,datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, LoggingEventHandler
import os,logging
from qcloud_cos import CosConfig,CosServiceError
from qcloud_cos import CosS3Client
#环境依赖 && 官方文档
#pip install -U cos-python-sdk-v5
#https://cloud.tencent.com/document/product/436/12269
class ScriptEventHandler(FileSystemEventHandler):

    def __init__(self,secret_id,secret_key,region,bucket,localpath):
        self.localpath=localpath
        self.bucket=bucket
        region = region  # 替换为用户的 Region
        token = None  # 使用临时密钥需要传入 Token，默认为空，可不填
        scheme = 'https'  # 指定使用 http/https 协议来访问 COS，默认为 https，可不填
        config = CosConfig(Region=region, SecretId=secret_id, SecretKey=secret_key, Token=token, Scheme=scheme)
        self.client = CosS3Client(config)
        FileSystemEventHandler.__init__(self)

    def getpush_pathfile(self,path):
        osspushfilename=str(path.replace(self.localpath+"\\",'')).replace('\\','/')
        return osspushfilename

    def getfilename(self,path):
        filename = path.split("\\")[-1:][0]
        return filename


    #oss文件上传默认覆盖上传
    @staticmethod
    def __ossupdload(client,localfilename,destfilename,bucket):
        response = client.upload_file(
            Bucket=bucket,
            LocalFilePath=localfilename,
            Key=destfilename,
            PartSize=1,
            MAXThread=10,
            EnableMD5=False
        )
        logging.info(response['ETag'])


    #oss文件删除
    @staticmethod
    def __ossdeletefile(client,bucket,filename):
        response = client.delete_object(
            Bucket=bucket,
            Key=filename
        )
        logging.info(type(response))

    #oss目录删除
    @staticmethod
    def __ossdeldir(client,bucket,to_delete_dir):
        try:
            response = client.delete_object(
                Bucket=bucket,
                Key=to_delete_dir,
            )
            logging.info(response)
        except CosServiceError as e:
            logging.info(e.get_status_code())

    #oss文件下载
    @staticmethod
    def __ossdownload(client,bucket,destfilename,localfilename):
        response = client.download_file(
            Bucket=bucket,
            Key=destfilename,
            DestFilePath=localfilename
        )
        logging.info(response['ETag'])

    # 文件移动
    def on_moved(self, event):
        if event.is_directory:
            print("directory moved from {src_path} to {dest_path}".format(src_path=event.src_path,
                                                                       dest_path=event.dest_path))
        else:
            # 删除老文件event.src_path
            # 创建新文件event.dest_path
            print("file moved from {src_path} to {dest_path}".format(src_path=event.src_path, dest_path=event.dest_path))
            localfilename=self.getpush_pathfile(event.src_path)
            print("要删除的文件名为："+localfilename)
            self.__ossdeletefile(client=self.client,bucket=self.bucket,filename=localfilename)
            path = (event.dest_path)
            print("上传的文件名为:" + self.getpush_pathfile(path))
            self.__ossupdload(client=self.client,bucket=self.bucket,destfilename=self.getpush_pathfile(path),localfilename=path)



    # 文件新建
    def on_created(self, event):
        if event.is_directory:
            #新建目录
            print("directory created:{file_path}".format(file_path=event.src_path))
            print(type(event.src_path))
        else:
            #如果创建新文件默认上传到OSS
            #本地变更路径

            print("file created:{file_path}".format(file_path=event.src_path))
            #文件上传
            path = (event.src_path)
            time.sleep(10)
            print("上传的文件名为:" + self.getpush_pathfile(path))
            self.__ossupdload(client=self.client,bucket=self.bucket,destfilename=self.getpush_pathfile(path),localfilename=path)


    # 文件删除
    def on_deleted(self, event):

        if event.is_directory:
            print("log event{logtype} directory deleted:{file_path}".format(logtype=event.event_type ,file_path=event.src_path)
 )           #删除老文件夹
            path=self.getpush_pathfile(event.src_path)
            print("要删除的文件夹为"+path)
            self.__ossdeldir(client=self.client,bucket=self.bucket,to_delete_dir=path)

        else:
            #删除文件
            print("文件删除 :{file_path}".format(file_path=event.src_path))
            localfilename=self.getpush_pathfile(event.src_path)
            print("要删除的文件名为："+localfilename)
            self.__ossdeletefile(client=self.client,bucket=self.bucket,filename=localfilename)
 
    # 文件修改
    def on_modified(self, event):
        if event.is_directory:
            print("目录修改:{file_path}".format(file_path=event.src_path))
        else:
            print("文件修改:{file_path}".format(file_path=event.src_path))
            path = (event.src_path)
            print("上传的文件名为:" + self.getpush_pathfile(path))
            self.__ossupdload(client=self.client,bucket=self.bucket,destfilename=self.getpush_pathfile(path),localfilename=path)

 
if __name__ == "__main__":
    secret_id = ''  # 替换为用户的 secretId(登录访问管理控制台获取)
    secret_key = ''  # 替换为用户的 secretKey(登录访问管理控制台获取)
    event_handler1 = ScriptEventHandler(secret_id=secret_id,secret_key=secret_key,bucket='jp-1301785062',region='ap-tokyo',localpath="d:\\eeb8.web")
    observer = Observer()
    watch = observer.schedule(event_handler1,path="d:\\eeb8.web",recursive=True)

    """
    配置日志
    """
    baseDir = os.path.dirname(os.path.abspath(__file__))
    logDir = os.path.join(baseDir, "logs")
    if not os.path.exists(logDir):
        os.makedirs(logDir)  # 创建路径
    logFile = datetime.datetime.now().strftime("%Y-%m-%d") + ".log"
    file_handler=logging.FileHandler(logDir+'\\'+logFile)
    logger=logging.getLogger('updateSecurity')
    logger.setLevel('DEBUG')
    logger.setLevel('INFO')
    logger.addHandler(file_handler)
    logging.basicConfig(level=logging.INFO,
                       format='%(asctime)s - %(message)s',
                       datefmt='%Y-%m-%d %H:%M:%S')
    sync_event_handler = LoggingEventHandler(logger)
    observer.add_handler_for_watch(sync_event_handler, watch)  # 为watch新添加一个event handler
    observer.start()
    # #################################################
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        observer.join()
