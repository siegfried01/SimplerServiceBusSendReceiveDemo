#r "nuget: Microsoft.Azure.ServiceBus, 5.2.0"    
#r "nuget: Azure.Messaging.ServiceBus, 7.11.1"
#r "nuget: Microsoft.Identity.Client, 4.48.1"
// https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues?tabs=connection-string 
using System;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using static System.Environment;
using static System.Console;
string connectionString = GetEnvironmentVariable("serviceBusConnectionString");
string spaceName = GetEnvironmentVariable("busNS");
string queueName = GetEnvironmentVariable("queue");


// the client that owns the connection and can be used to create senders and receivers
ServiceBusClient client;

// the processor that reads and processes messages from the queue
ServiceBusProcessor processor;

// The Service Bus client types are safe to cache and use as a singleton for the lifetime
// of the application, which is best practice when messages are being published or read
// regularly.
//
// Set the transport type to AmqpWebSockets so that the ServiceBusClient uses port 443. 
// If you use the default AmqpTcp, make sure that ports 5671 and 5672 are open.

// TODO: Replace the <NAMESPACE-CONNECTION-STRING> and <QUEUE-NAME> placeholders
var clientOptions = new ServiceBusClientOptions()
{
    TransportType = ServiceBusTransportType.AmqpWebSockets
};
client = new ServiceBusClient(connectionString, clientOptions);

// create a processor that we can use to process the messages
// TODO: Replace the <QUEUE-NAME> placeholder
processor = client.CreateProcessor(queueName, new ServiceBusProcessorOptions());

try
{
    // add handler to process messages
    processor.ProcessMessageAsync += MessageHandler;

    // add handler to process any errors
    processor.ProcessErrorAsync += ErrorHandler;

    // start processing 
    await processor.StartProcessingAsync();

    WriteLine("Wait for a minute and then press any key to end the processing");
    //Console.ReadKey();
    System.Threading.Thread.Sleep(1000);

    // stop processing 
    WriteLine("\nStopping the receiver...");
    await processor.StopProcessingAsync();
    WriteLine("Stopped receiving messages");
}
finally
{
    // Calling DisposeAsync on client types is required to ensure that network
    // resources and other unmanaged objects are properly cleaned up.
    await processor.DisposeAsync();
    await client.DisposeAsync();
}

// handle received messages
async Task MessageHandler(ProcessMessageEventArgs args)
{
    string body = args.Message.Body.ToString();
    WriteLine($"Received: {body}");

    // complete the message. message is deleted from the queue. 
    await args.CompleteMessageAsync(args.Message);
}

// handle any errors when receiving messages
Task ErrorHandler(ProcessErrorEventArgs args)
{
    WriteLine(args.Exception.ToString());
    return Task.CompletedTask;
}
