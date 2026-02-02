import boto3
from datetime import date, timedelta
from collections import defaultdict
import os

dynamodb = boto3.resource("dynamodb")

RAW_TABLE = os.environ["RAW_TABLE"]
ANALYSIS_TABLE = os.environ["ANALYSIS_TABLE"]

raw_table = dynamodb.Table(RAW_TABLE)
analysis_table = dynamodb.Table(ANALYSIS_TABLE)


def get_daily_total(target_date):
    response = raw_table.scan(
        FilterExpression="#d = :date",
        ExpressionAttributeNames={"#d": "date"},
        ExpressionAttributeValues={":date": target_date},
    )

    return sum(float(item["cost"]) for item in response.get("Items", []))


def get_monthly_total(year, month):
    response = raw_table.scan()
    total = 0.0

    for item in response.get("Items", []):
        item_date = item["date"]
        if item_date.startswith(f"{year}-{month:02d}"):
            total += float(item["cost"])

    return total


def lambda_handler(event, context):
    today = date.today()
    yesterday = today - timedelta(days=1)
    day_before = today - timedelta(days=2)

    # ---------------- DAILY ----------------
    current_daily = get_daily_total(yesterday.strftime("%Y-%m-%d"))
    previous_daily = get_daily_total(day_before.strftime("%Y-%m-%d"))

    daily_pct = None
    if previous_daily > 0:
        daily_pct = ((current_daily - previous_daily) / previous_daily) * 100

    analysis_table.put_item(
        Item={
            "analysis_type": "daily",
            "date": yesterday.strftime("%Y-%m-%d"),
            "current_total": round(current_daily, 2),
            "previous_total": round(previous_daily, 2),
            "percentage_change": round(daily_pct, 2) if daily_pct else None,
            "trend": "increase" if daily_pct and daily_pct > 0 else "decrease",
        }
    )

    # ---------------- MONTHLY ----------------
    current_month_total = get_monthly_total(today.year, today.month)

    prev_month = today.month - 1 or 12
    prev_year = today.year if today.month != 1 else today.year - 1
    previous_month_total = get_monthly_total(prev_year, prev_month)

    monthly_pct = None
    if previous_month_total > 0:
        monthly_pct = (
            (current_month_total - previous_month_total)
            / previous_month_total
        ) * 100

    analysis_table.put_item(
        Item={
            "analysis_type": "monthly",
            "date": f"{today.year}-{today.month:02d}",
            "current_total": round(current_month_total, 2),
            "previous_total": round(previous_month_total, 2),
            "percentage_change": round(monthly_pct, 2) if monthly_pct else None,
            "trend": "increase" if monthly_pct and monthly_pct > 0 else "decrease",
        }
    )

    return {"status": "analysis completed"}
