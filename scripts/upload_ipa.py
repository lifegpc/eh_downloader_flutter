import argparse
import requests
from requests.auth import HTTPBasicAuth
import os

def upload_ipa(baseurl: str, file_path: str, username: str, password: str):
    url = f"{baseurl}/api/upload"
    basic = HTTPBasicAuth(username, password)
    re = requests.post(url, files={"file": open(file_path, "rb")}, auth=basic, timeout=60)
    json = re.json()
    if "err" in json and json["err"]:
        raise Exception(f"Error uploading file: {json['err']}")
    print("Uploaded file successfully")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Upload an IPA file to the server")
    parser.add_argument("baseurl", help="The base URL of the server")
    parser.add_argument("file", help="The IPA file to upload")
    parser.add_argument("username", help="The username to authenticate with")
    parser.add_argument("password", help="The password to authenticate with")
    args = parser.parse_args()
    upload_ipa(args.baseurl, args.file, args.username, args.password)
