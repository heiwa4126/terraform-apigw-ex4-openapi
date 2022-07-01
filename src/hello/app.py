import json
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools.event_handler import APIGatewayRestResolver

tracer = Tracer()
logger = Logger()
app = APIGatewayRestResolver()


def lambda_handler(event, context):
    return app.resolve(event, context)


def res1(msg):
    return {"message": msg}


def res2(n):
    return {"result": n}


@app.get("/hello")
@tracer.capture_method
def hello():
    return res1("hello world!")


@app.get("/hello/<name>")
@tracer.capture_method
def hello_name(name):
    return res1(f"hello {name}!")


@app.get("/goodbye")
@tracer.capture_method
def goodbye():
    return res1("goodbye cruel world...")


@app.get("/add")
@tracer.capture_method
def add_get():
    # 存在だけはAPIGWでチェック済み。数字になるかは不明
    a = float(app.current_event.get_query_string_value(name="a", default_value=0))
    b = float(app.current_event.get_query_string_value(name="b", default_value=0))
    return res2(a + b)


@app.post("/add")
@tracer.capture_method
def add_post():
    q = app.current_event.json_body
    return res2(q["a"] + q["b"])
