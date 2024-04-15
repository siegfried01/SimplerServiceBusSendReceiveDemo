#r "nuget: Microsoft.Azure.ServiceBus, 5.2.0"    
#r "nuget: Azure.Messaging.ServiceBus, 7.11.1"
#r "nuget: Microsoft.Identity.Client, 4.48.1"
// https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues?tabs=connection-string 


/*
 This was working <Fri Mar 29, 2024> to no more <8:04pm Mon Apr 1, 2024>
 Howevever the servieBusExplorer can write messages.
dotnet script ServiceBusSendSimpleMainProgram.csx 1
see https://github.com/Azure/azure-sdk-for-net/blob/main/sdk/servicebus/Azure.Messaging.ServiceBus/TROUBLESHOOTING.md#find-information-about-a-servicebusexception
System.UnauthorizedAccessException: Put token failed. status-code: 401, status-description: InvalidSignature: The token has an invalid signature..
For troubleshooting information, see https://aka.ms/azsdk/net/servicebus/exceptions/troubleshoot.
   at Azure.Messaging.ServiceBus.Amqp.AmqpConnectionScope.CreateSendingLinkAsync(String entityPath, String identifier, AmqpConnection connection, TimeSpan timeout, CancellationToken cancellationToken)
   at Azure.Messaging.ServiceBus.Amqp.AmqpConnectionScope.OpenSenderLinkAsync(String entityPath, String identifier, TimeSpan timeout, CancellationToken cancellationToken)
   at Azure.Messaging.ServiceBus.Amqp.AmqpSender.CreateLinkAndEnsureSenderStateAsync(TimeSpan timeout, CancellationToken cancellationToken)
   at Microsoft.Azure.Amqp.FaultTolerantAmqpObject`1.OnCreateAsync(TimeSpan timeout, CancellationToken cancellationToken)
   at Microsoft.Azure.Amqp.Singleton`1.GetOrCreateAsync(TimeSpan timeout, CancellationToken cancellationToken)
   at Microsoft.Azure.Amqp.Singleton`1.GetOrCreateAsync(TimeSpan timeout, CancellationToken cancellationToken)
   at Azure.Messaging.ServiceBus.Amqp.AmqpSender.CreateMessageBatchInternalAsync(CreateMessageBatchOptions options, TimeSpan timeout)
   at Azure.Messaging.ServiceBus.Amqp.AmqpSender.<>c.<<CreateMessageBatchAsync>b__19_0>d.MoveNext()
--- End of stack trace from previous location ---
   at Azure.Messaging.ServiceBus.ServiceBusRetryPolicy.RunOperation[T1,TResult](Func`4 operation, T1 t1, TransportConnectionScope scope, CancellationToken cancellationToken, Boolean logRetriesAsVerbose)
   at Azure.Messaging.ServiceBus.ServiceBusRetryPolicy.RunOperation[T1,TResult](Func`4 operation, T1 t1, TransportConnectionScope scope, CancellationToken cancellationToken, Boolean logRetriesAsVerbose)
   at Azure.Messaging.ServiceBus.Amqp.AmqpSender.CreateMessageBatchAsync(CreateMessageBatchOptions options, CancellationToken cancellationToken)
   at Azure.Messaging.ServiceBus.ServiceBusSender.CreateMessageBatchAsync(CreateMessageBatchOptions options, CancellationToken cancellationToken)
   at Submission#0.<<Initialize>>d__0.MoveNext() in c:\Users\shein\Documents\WinOOP\Examples\Azure\ServiceBus\SimpleSendAndReceive\ServiceBusSendSimpleMainProgram.csx:line 40
--- End of stack trace from previous location ---
   at Dotnet.Script.Core.ScriptRunner.Execute[TReturn](String dllPath, IEnumerable`1 commandLineArgs) in C:\Users\VssAdministrator\AppData\Local\Temp\tmp31E6\Dotnet.Script.Core\ScriptRunner.cs:line 110

Compilation exited abnormally with code 1 at Mon Apr  1 20:02:44


*/
using System;
using Azure.Messaging.ServiceBus;
using static System.Environment;
using static System.Console;
string connectionString = GetEnvironmentVariable("serviceBusConnectionString");
string spaceName = GetEnvironmentVariable("busNS");
string queueName = GetEnvironmentVariable("queue");

// the client that owns the connection and can be used to create senders and receivers
ServiceBusClient client;

// the sender used to publish messages to the queue
ServiceBusSender sender;

// number of messages to be sent to the queue
const int numOfMessages = 3;

// The Service Bus client types are safe to cache and use as a singleton for the lifetime
// of the application, which is best practice when messages are being published or read
// regularly.
//
// set the transport type to AmqpWebSockets so that the ServiceBusClient uses the port 443. 
// If you use the default AmqpTcp, you will need to make sure that the ports 5671 and 5672 are open

// TODO: Replace the <NAMESPACE-CONNECTION-STRING> and <QUEUE-NAME> placeholders
var clientOptions = new ServiceBusClientOptions()
{
    TransportType = ServiceBusTransportType.AmqpWebSockets
};
client = new ServiceBusClient(connectionString, clientOptions);
sender = client.CreateSender(queueName);

WriteLine($"Write to queue={queueName} in ns={spaceName} cn={connectionString}");
// create a batch 
using (ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync()){

        for (int i = 1; i <= numOfMessages; i++)
        {
            // try adding a message to the batch
            if (!messageBatch.TryAddMessage(new ServiceBusMessage($"Message {i} {DateTime.Now}")))
            {
                // if it is too large for the batch
                throw new Exception($"The message {i} is too large to fit in the batch.");
            }
        }

        try
        {
            // Use the producer client to send the batch of messages to the Service Bus queue
            await sender.SendMessagesAsync(messageBatch);
            WriteLine($"A batch of {numOfMessages} messages has been published to the queue.");
        }
        finally
        {
            // Calling DisposeAsync on client types is required to ensure that network
            // resources and other unmanaged objects are properly cleaned up.
            await sender.DisposeAsync();
            await client.DisposeAsync();
        }

        //WriteLine("Press any key to end the application");
        //Console.ReadKey();
}
