import boto3
from datetime import date, timedelta
import json
import os
from decimal import Decimal

ce = boto3.client("ce")
dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")

TABLE_NAME = os.environ["DYNAMODB_TABLE"]
BUCKET_NAME = os.environ["S3_BUCKET"]

def lambda_handler(event, context):
    today = date.today()
    yesterday = today - timedelta(days=1)

    response = ce.get_cost_and_usage(
        TimePeriod={
            "Start": yesterday.strftime("%Y-%m-%d"),
            "End": today.strftime("%Y-%m-%d"),
        },
        Granularity="DAILY",
        Metrics=["UnblendedCost"],
        GroupBy=[
            {"Type": "DIMENSION", "Key": "SERVICE"}
        ],
    )

    table = dynamodb.Table(TABLE_NAME)

    for group in response["ResultsByTime"][0]["Groups"]:
        service = group["Keys"][0]
        amount = group["Metrics"]["UnblendedCost"]["Amount"]

        table.put_item(
            Item={
                "service_name": service,
                "date": yesterday.strftime("%Y-%m-%d"),
                "cost": Decimal(amount)
            }
        )

    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=f"daily/{yesterday}.json",
        Body=json.dumps(response),
    )

    return {
        "status": "success",
        "date": str(yesterday)
    }
