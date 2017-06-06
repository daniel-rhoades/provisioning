import boto3

def lambda_handler(event, context):

    message = event['Records'][0]['Sns']['Message']
    # print("From SNS: " + message)

    firehose = boto3.client('firehose')

    firehose.put_record(
        DeliveryStreamName='datalake-ingest',
        Record={
            'Data': message + '\n'
        })

    return message