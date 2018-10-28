import boto3
import time
sys.path.append("..")
import conf as c

client = boto3.client('kinesis', region_name=c.region_name)
response = client.describe_stream(StreamName=c.stream_name)

# print(response)

shard_id = response['StreamDescription']['Shards'][0]['ShardId']
shard_iterator = client.get_shard_iterator(StreamName=c.stream_name,
                                                      ShardId=shard_id,
                                                      ShardIteratorType='LATEST')

shard_iterator = shard_iterator['ShardIterator']
record_response = client.get_records(ShardIterator=shard_iterator,
                                              Limit=2)

while 'NextShardIterator' in record_response:
    record_response = client.get_records(ShardIterator=record_response['NextShardIterator'],
                                                  Limit=2)

    print(record_response)
    # wait for 5 seconds
    time.sleep(1.5)