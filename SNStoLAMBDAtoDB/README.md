# SNS to Lambda to DB

This microservice is responsible for Lambda receiving a message from SNS and storing it in a DynamoDB table.

---
## Requirements

### DynamoDB Table
+ partition key

### Lambda Function
+ DynamoDB Client
+ putItem for DynamoDB table

### SNS Topic
#### Subscription
+ Protocol: Lambda
+ Endpoint: arn of Lambda function

---
### Policies & Roles

#### Policy for Cloudwatch Logs from Lambda
+ allow:
    - CreateLogGroup
    - CreateLogStream
    - PutLogEvents
+ arn of Cloudwatch Logs Group
#### Policy attached to Lambda-Role

#### Policy for reading from SNS
+ allow:
    - GetSubscriptionAttributes
    - GetTopicAttributes
    - GetEndpointAttributes
+ arn of SNS topic
#### Policy attached to Lambda-Role

#### Policy for writing to DynamoDB
+ allow:
    - PutItem
+ arn of DynamoDB table

#### Policy attached to Lambda-Role

---