import os
import http.client
import json
import re


def upload_file(host, file_path, token, destination_path, as_task=True):
    """
    将文件上传到指定URL路径

    :param host: API的URL
    :param file_path: 本地文件路径
    :param token: 认证token
    :param destination_path: 在服务器上的目标路径
    :param as_task: 是否作为任务异步上传（默认为True）
    """
    # 打开文件并读取内容
    with open(file_path, "rb") as file:
        file_content = file.read()

    # 设置请求头
    headers = {
        "Authorization": f"{token}",
        "File-Path": destination_path,
        "As-Task": str(as_task).lower(),  # 将布尔值转为字符串形式 'true' 或 'false'
        "Content-Length": str(len(file_content)),
        "Content-Type": "application/octet-stream",
    }

    # 建立连接并发送 PUT 请求
    connection = http.client.HTTPConnection(host)
    try:
        connection.request("PUT", "/api/fs/put", body=file_content, headers=headers)
        response = connection.getresponse()

        # 输出响应结果
        if response.status == 200:
            print("文件上传成功！")
        else:
            print("文件上传失败，状态码:", response.status)
            print("响应内容:", response.read().decode())
    except Exception as e:
        print("文件上传请求失败:", e)
    finally:
        connection.close()


def upload_all(url, token, destination_dirs):
    """
    将文件上传到所有网盘中

    :param url: API的URL
    :param token: 认证token
    :param destination_dirs: 在服务器上的目标文件夹列表
    """
    pattern = r"v\d+\.\d+\.\d+"
    files = os.listdir("./output")  # pdf的输出目录
    for file_name in files:  # 输出的三个pdf
        versions = re.findall(pattern, file_name)
        for dest_dir in destination_dirs:  # pdf上传到多个网盘上，已经挂在到alist上。
            dest_file = f"{dest_dir}/{versions[0]}/{file_name}"  # 上传到服务器上的路径
            upload_file(url, f"./output/{file_name}", token, dest_file)


# 从环境变量读取URL和用户名密码
url = os.getenv("ALIST_URL")
alist_username = os.getenv("ALIST_USERNAME")
alist_password = os.getenv("ALIST_PASSWORD")
destination_dirs = os.getenv("ALIST_DEST_DIRS")
destination_dirs = destination_dirs.split(";")  # 注意 以分号分隔，非空字符串
destination_dirs = [s for s in destination_dirs if s]  # 过滤掉空的字符串


login_payload = json.dumps({"username": alist_username, "password": alist_password})
headers = {"Content-Type": "application/json"}

# 建立登录连接
connection = http.client.HTTPConnection(url)
try:
    connection.request("POST", "/api/auth/login", body=login_payload, headers=headers)
    response = connection.getresponse()

    # 确认登录请求成功
    if response.status == 200:
        # 获取 token
        token_data = json.loads(response.read().decode("utf-8"))
        token = token_data.get("data").get("token")
        if not token:
            print("未能从登录响应中获取token，请检查API响应。")
        else:
            upload_all(url,   token, destination_dirs)
    else:
        print("登录失败，状态码:", response.status)
        print("响应内容:", response.read().decode())
except Exception as e:
    print("登录请求失败:", e)
finally:
    connection.close()
