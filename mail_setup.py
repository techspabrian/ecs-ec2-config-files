import boto3
import base64
import json
from botocore.exceptions import ClientError

secret_id="smtp_login"
region="us-west-2"

def get_secret( sn, rn):

    secret_name = sn
    region_name = rn

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
            return secret
        else:
            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])


secret=get_secret( secret_id, region)
obj=json.loads(secret)
f = open("/root/.mailrc", "w") 
f.write("set smtp-use-starttls\n")
f.write("set ssl-verify=ignore\n")
f.write("set smtp-auth=login\n")
f.write("set smtp=smtp://email-smtp.{}.amazonaws.com:587\n".format(region))
f.write("set from=\"alerts@techspabrian.com\"\n")
f.write("set smtp-auth-user={}\n".format(obj['mail_user'])) 
f.write("set smtp-auth-password={}\n".format(obj['mail_pw'])) 
f.write("set ssl-verify=ignore\n")
f.write("set nss-config-dir=\"/etc/pki/nssdb/\"\n") 
f.close()



