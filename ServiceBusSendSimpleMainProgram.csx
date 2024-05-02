#r "nuget: Microsoft.Azure.ServiceBus, 5.2.0"    
#r "nuget: Azure.Messaging.ServiceBus, 7.11.1"
#r "nuget: Microsoft.Identity.Client, 4.48.1"

// Install C# script with "dotnet tool install -g dotnet-script" (see https://github.com/dotnet-script/dotnet-script)
// Run this script with the command "dotnet script ServiceBusSendSimpleMainProgram.csx"
// This C# code comes from  https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues?tabs=connection-string 
//
// use this with (for example)  az webapp log tail -g rg_siegfriedServiceBusSimpleSendReceive -n l2ydjsjlzxaoe-func

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
const int numOfMessages = 4;

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
int count = 0;
string logSequenceNumberFileName = "log-sequence-number.txt";
if(System.IO.File.Exists(logSequenceNumberFileName))
{
    if(int.TryParse(System.IO.File.ReadAllText(logSequenceNumberFileName), out count))
    {
        count++;
        System.IO.File.WriteAllText(logSequenceNumberFileName, count.ToString());
    }
    else
    {
        System.IO.File.WriteAllText(logSequenceNumberFileName, "0" + Environment.NewLine);
    }            
}
else
{
    System.IO.File.WriteAllText(logSequenceNumberFileName, "0" + Environment.NewLine);
}

WriteLine($"Write to queue={queueName} in ns={spaceName} cn={connectionString} count={count}");
// create a batch 
using (ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync()){

        for (int i = 1; i <= numOfMessages; i++)
        {
            var msg = $"Message {count:D5}-{i} "+DateTime.Now.ToString("ddd yyyy MM dd hh:mm:ss.fff tt (zzz)");
            WriteLine($"msg added to queue={msg}");
            // try adding a message to the batch
            if (!messageBatch.TryAddMessage(new ServiceBusMessage(msg)))
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
