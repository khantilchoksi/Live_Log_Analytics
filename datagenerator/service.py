import boto3, csv, random, time
import conf as c

client = boto3.client('kinesis', region_name='us-east-1')

with open(c.datafile) as csvfile:
    reader = csv.DictReader(csvfile)
    raw_records = list(reader)

# print(raw_records[:5])
clean_records = []
for record in raw_records:
    curr_record = list(record.values())
    curr_record[1] = curr_record[1][1:]
    cleaned_endpoint = curr_record[2].split(".")[0]
    cleaned_endpoint = cleaned_endpoint.split("/")[-1]
    curr_record[2] = cleaned_endpoint
    curr_record.append(random.uniform(c.min_delay_response, c.max_delay_response))
    curr_record[-1] = round(curr_record[-1], 2)
    clean_records.append(curr_record)

print([random.choice(clean_records) for i in range(10)])

start_point = random.randint(0, len(clean_records)-1)

while True:
    current_record = clean_records[start_point]
    data  = bytes(current_record)
    print(data)
    response = client.put_records(
        StreamName = c.stream_name,
        Data = data,
        PartitionKey = current_record[2]
    )
    start_point = (start_point+1) % len(clean_records)
    time.sleep(random.uniform(c.min_delay_record, c.max_delay_record))

