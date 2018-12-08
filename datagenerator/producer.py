import boto3, csv, random, time
import sys
import json
sys.path.append("..")
import conf as c
import json

client = boto3.client('kinesis', region_name=c.region_name)

with open(c.datafile) as csvfile:
    reader = csv.DictReader(csvfile)
    raw_records = list(reader)

# print(raw_records[:5])
clean_records = []
for record in raw_records:
    curr_record = list(record.values())
    curr_record[1] = curr_record[1][1:]
    # cleaned_endpoint = curr_record[2].split(".")[0]
    # cleaned_endpoint = cleaned_endpoint.split("/")[-1]
    # curr_record[2] = cleaned_endpoint
    curr_record.append(random.uniform(c.min_delay_response, c.max_delay_response))
    curr_record[-1] = round(curr_record[-1], 2)
    clean_records.append(curr_record)

# print([random.choice(clean_records) for i in range(10)])

start_point = random.randint(0, len(clean_records)-1)
possible_endpoints = ['home','contest','login','profile','logout','submission']
possible_errors = [['404','200','302'], 
        ['404','505'], 
        ['302'], 
        ['200'], 
        ['404'], 
        ['404','200','302','505']]
#possible_errors = [['200','302'],
#        ['200','505'],
#        ['200'],
#        ['200'],
#        ['200'],
#        ['200','404']]
possible_range = [(100,200),(300,400), (500,700),(1000,1500), (1000,1400),(400,1200)]

try:
    while True:
        current_record = clean_records[start_point]
        current_record = [str(i) for i in current_record]
        # Format of data: [b'10.130.2.1', b'29/Jan/2018:20:21:57', b'home', b'302', b'3.98']
        random_endpoint_index = random.randint(0, len(possible_endpoints)-1)

        data  = {
            'ip': current_record[0],
            'timestamp': current_record[1],
            'endpoint': possible_endpoints[random_endpoint_index],
            'response_code': possible_errors[random_endpoint_index][random.randint(0, len(possible_errors[random_endpoint_index])-1)],
            'response_time': random.randint(possible_range[random_endpoint_index][0], possible_range[random_endpoint_index][1])
        }
        response = client.put_record(
            StreamName = c.stream_name,
            Data = json.dumps(data),
            PartitionKey = current_record[2]
        )
        print(f'Data: {current_record} Response: {response}')
        start_point = (start_point+1) % len(clean_records)
        time.sleep(0.001*random.uniform(c.min_delay_record, c.max_delay_record))
except KeyboardInterrupt:
    print("Producer exiting..!")
    sys.exit()


