import boto3
import time
import sys
sys.path.append("..")
import conf as c
import json

# Kiniesis client
client = boto3.client('kinesis', region_name=c.region_name)
response = client.describe_stream(StreamName=c.stream_name)
# DynamoDB
dynamodb = boto3.resource('dynamodb', region_name=c.region_name)
table = dynamodb.Table(c.table_name)

print(f'Describe Stream: {response}')

shard_id = response['StreamDescription']['Shards'][int(sys.argv[1])]['ShardId']
shard_iterator = client.get_shard_iterator(StreamName=c.stream_name,
                                                      ShardId=shard_id,
                                                      ShardIteratorType='LATEST')

shard_iterator = shard_iterator['ShardIterator']
record_response = client.get_records(ShardIterator=shard_iterator,
                                              Limit=2)

while 'NextShardIterator' in record_response:
    record_response = client.get_records(ShardIterator=record_response['NextShardIterator'],
                                                  Limit=2)

    # print(record_response)
    for r in record_response['Records']:
        l = r['Data'].decode()
        # item = {
        #     'endpoint': l[2],
        #     'timestamp': l[1],
        #     'ip': l[0],
        #     'region': 'USA',
        #     'response_code': l[3],
        #     'response_time': l[4]
        # }
        table.put_item(Item=json.loads(l))
        print(f"Partition Key: {r['PartitionKey']} ")
    # wait for 5 seconds
    time.sleep(1.5)
