import requests

newdict = {
    "context": "The GDP of the United States is pretty large I think",
    "question": "What is the GDP of the United States?"
}

response = requests.post("http://127.0.0.1:5000/post", json=newdict)
print(response.text)