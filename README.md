# ApiGateway Proxy to Spring Container using LocalStack

This assumes you have `awslocal` installed to simplify the calls to localstack.
```
pip install awscli-local
```
Otherwise, you can substitute the calls to this by passing in the localstack endpoint
```
aws ...  --endpoint-url=http://localstack:4566
```

You'll also need [docker-compose](https://docs.docker.com/compose/install/).

## Steps to build and run:
1. The container for the Spring Boot application needs to be built with Docker

(The tag name can be whatever you want, but must be updated in the [./docker-compose.yaml](./docker-compose.yaml) file.)
```sh
docker build . -t scgrk/shw
```

2. Start the docker services and wait for everything to be ready.
```sh
docker-compose up
```

You'll know when the Spring Application is running when you see:
```
spring-helloworld_1  | 2021-03-05 18:28:56.532  INFO 112 --- [           main] c.s.helloworld.HelloWorldApplication     : Started HelloWorldApplication in 0.808 seconds (JVM running for 0.992)
```

You'll know localstack is ready when you see:
```
localstack_demo      | Waiting for all LocalStack services to be ready
localstack_demo      | Ready.
localstack_demo      | 2021-03-05T18:47:22:INFO:localstack.utils.analytics.profiler: Execution of "start_api_services" took 5047.660112380981ms
```

If your Spring container has the dependencies cached already, it may be ready before localstack. Otherwise, if downloading the dependencies, it is likely localstack will be ready before Spring.

3. Create a new CloudFormation stack on LocalStack
```sh
awslocal cloudformation create-stack --stack-name 'test-stack' --template-body file://gateway.yaml
```

This will create a CF stack on localstack and give you information about the creation.
```
----------------------------------------------------------------------------------------
|                                      CreateStack                                     |
+---------+----------------------------------------------------------------------------+
|  StackId|  arn:aws:cloudformation:us-east-1:000000000000:stack/test-stack/6f37f385   |
+---------+----------------------------------------------------------------------------+
```
Your output may differ and be presented as JSON or YAML depending on your default output settings.

4. Get the RestApiId from the stack output.
```sh
awslocal cloudformation describe-stacks --stack-name test-stack --output table
```
Which will output:
```
-----------------------------------------------------------------------------------------------
|                                       DescribeStacks                                        |
+---------------------------------------------------------------------------------------------+
||                                          Stacks                                           ||
|+--------------+----------------------------------------------------------------------------+|
||  CreationTime|  2021-03-05T19:57:49.474000+00:00                                          ||
||  StackId     |  arn:aws:cloudformation:us-east-1:000000000000:stack/test-stack/6f37f385   ||
||  StackName   |  test-stack                                                                ||
||  StackStatus |  CREATE_COMPLETE                                                           ||
|+--------------+----------------------------------------------------------------------------+|
|||                                         Outputs                                         |||
||+------------------------------------+----------------------------------------------------+||
|||  Description                       |                                                    |||
|||  ExportName                        |  RestApiID                                         |||
|||  OutputKey                         |  RestApiResourceId                                 |||
|||  OutputValue                       |  oxosx0ft3n                                        |||
||+------------------------------------+----------------------------------------------------+||
```

The RestApiId is the `OutputValue`

5. Test the integration between ApiGateway and the SpringBoot container running locally
The endpoint to hit on Postman comes in the form:
```
http://localhost:4566/restapis/<REST_API_ID>/v0/_user_request_/mock
```

With the example output above, we'll use

```
http://localhost:4566/restapis/oxosx0ft3n/v0/_user_request_/mock
```

This will then proxy to the Spring application and return the result.

![](./postman-result.png)
