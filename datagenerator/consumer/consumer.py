import boto3
import conf as c

client = boto3.client('kinesis', region_name=c)