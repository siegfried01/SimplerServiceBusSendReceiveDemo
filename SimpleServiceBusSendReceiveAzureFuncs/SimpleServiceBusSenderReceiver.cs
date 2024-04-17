using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using static System.Environment;

namespace SimpleServiceBusSendReceiveAzureFuncs;
public class SimpleServiceBusSenderReceiver
{
    /// <summary>
    /// This function will be triggered when a message is sent to the Service Bus queue.
    /// Using the portal, set the Service Bus connection string in the app settings under Connection Strings using type Custom.
    /// </summary>
    /// <param name="myQueueItem"></param>
    /// <param name="log"></param>
    [FunctionName("SimpleServiceBusReceiver")]
    public void Run([ServiceBusTrigger("mainqueue001", Connection = "ServiceBusConnection")] string myQueueItem, ILogger log)
    {
        log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
    }
    /*
    // https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-output?tabs=python-v2%2Cin-process%2Cnodejs-v4%2Cextensionv5&pivots=programming-language-csharp
    // This function will be triggered by HTTP request and will send a message to the Service Bus queue.
    // https://stackoverflow.com/questions/60607880/how-to-send-data-to-service-bus-topic-with-azure-functions
    [FunctionName("SimpleServiceBusSender")]
    [return: ServiceBus("mainqueue001", Connection = "ServiceBusConnection")]
    public static async Task RunAsync(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
        [ServiceBus("mainqueue001", Connection = "ServiceBusConnection")] MessageSender messagesQueue,
        ILogger log)
    {
        log.LogInformation("C# HTTP trigger function processed a request.");
            string name = req.Query["name"];
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        dynamic data = JsonConvert.DeserializeObject(requestBody);
        name = name ?? data?.name;
            string responseMessage = string.IsNullOrEmpty(name)
            ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
            : $"Hello, {name}. This HTTP triggered function executed successfully.";
            byte[] bytes = Encoding.ASCII.GetBytes(responseMessage);
            Message m1 = new Message(bytes);
        await messagesQueue.SendAsync(m1);
    }

    //https://learn.microsoft.com/en-us/previous-versions/sandbox/functions-recipes/service-bus#azure-service-bus-output-binding
    [FunctionName("ServiceBusTimerOutput")]
    public static void Run([TimerTrigger("0/10 * * * * *")]TimerInfo myTimer,
                           TraceWriter log,
                           [ServiceBus("mainqueue001", Connection = "ServiceBusConnection", EntityType = EntityType.Queue)]out string queueMessage)
    {
        var now = DateTime.Now.ToString("ddd yyyy-MM-dd HH:mm:ss (ttt)");
        log.Info("101 Azure Function Demo - Azure Service Bus Queue output {now}",now);
        queueMessage = DateTime.UtcNow.ToString();
    } 
    */
    /*
    // Http Trigger function
    [FunctionName("SimpleHttpTriggerServiceBusSender")]
    public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
    {
        string name = req.Query["name"];

        string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        dynamic data = JsonConvert.DeserializeObject(requestBody);
        name = name ?? data?.name;

        string responseMessage = (string.IsNullOrEmpty(name)
            ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response. "
                    : $"Hello, {name}. This HTTP triggered function executed successfully. ") + System.DateTime.Now;

        log.LogInformation("C# HTTP trigger function processed a request. name={name}", name);

        string connectionString = GetEnvironmentVariable("ServiceBusConnection");
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

        log.LogInformation($"Write to queue={queueName} in ns={spaceName} cn=connectionString");
        // create a batch 
        using (ServiceBusMessageBatch messageBatch = await sender.CreateMessageBatchAsync())
        {

            for (int i = 1; i <= numOfMessages; i++)
            {
                // try adding a message to the batch
                if (!messageBatch.TryAddMessage(new ServiceBusMessage($"Message {i} name={name} {DateTime.Now}")))
                {
                    // if it is too large for the batch
                    throw new Exception($"The message {i} is too large to fit in the batch.");
                }
            }

            try
            {
                // Use the producer client to send the batch of messages to the Service Bus queue
                await sender.SendMessagesAsync(messageBatch);
                log.LogInformation($"A batch of {numOfMessages} messages has been published to the queue.");
            }
            finally
            {
                // Calling DisposeAsync on client types is required to ensure that network
                // resources and other unmanaged objects are properly cleaned up.
                await sender.DisposeAsync();
                await client.DisposeAsync();
            }


            return new OkObjectResult(responseMessage);
        }
    }
    */
}

